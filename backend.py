# backend/app.py
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import git
import looker_sdk
import json
import tempfile
import shutil
from datetime import datetime
import base64
from pathlib import Path
import subprocess
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# Configuration
class Config:
    GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
    LOOKER_BASE_URL = os.getenv('LOOKER_BASE_URL')
    LOOKER_CLIENT_ID = os.getenv('LOOKER_CLIENT_ID')
    LOOKER_CLIENT_SECRET = os.getenv('LOOKER_CLIENT_SECRET')
    WORKSPACE_DIR = os.getenv('WORKSPACE_DIR', './workspace')
    MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

config = Config()

# Initialize workspace directory
os.makedirs(config.WORKSPACE_DIR, exist_ok=True)

# Global variables for session management
current_repo = None
looker_client = None

class GitManager:
    def __init__(self, workspace_dir):
        self.workspace_dir = workspace_dir
        self.repo_path = None
        self.repo = None
    
    def clone_repository(self, repo_url, token=None):
        """Clone repository to workspace"""
        try:
            # Create repo-specific directory
            repo_name = repo_url.split('/')[-1].replace('.git', '')
            self.repo_path = os.path.join(self.workspace_dir, repo_name)
            
            # Remove existing directory if it exists
            if os.path.exists(self.repo_path):
                shutil.rmtree(self.repo_path)
            
            # Add token to URL if provided
            if token and 'github.com' in repo_url:
                repo_url = repo_url.replace('https://', f'https://{token}@')
            
            # Clone repository
            self.repo = git.Repo.clone_from(repo_url, self.repo_path)
            logger.info(f"Repository cloned to {self.repo_path}")
            return True
            
        except Exception as e:
            logger.error(f"Error cloning repository: {e}")
            return False
    
    def fetch_changes(self):
        """Fetch latest changes from remote"""
        try:
            if not self.repo:
                raise Exception("No repository loaded")
            
            origin = self.repo.remotes.origin
            origin.fetch()
            
            # Get fetch info
            fetch_info = {
                'success': True,
                'commits_behind': len(list(self.repo.iter_commits('HEAD..origin/main'))),
                'last_commit': str(self.repo.head.commit.hexsha[:7]),
                'message': 'Fetch completed successfully'
            }
            
            return fetch_info
            
        except Exception as e:
            logger.error(f"Error fetching changes: {e}")
            return {'success': False, 'error': str(e)}
    
    def commit_and_push(self, commit_message, files_to_add=None):
        """Commit changes and push to remote"""
        try:
            if not self.repo:
                raise Exception("No repository loaded")
            
            # Add files
            if files_to_add:
                for file_path in files_to_add:
                    self.repo.index.add([file_path])
            else:
                self.repo.git.add('.')
            
            # Check if there are changes to commit
            if not self.repo.index.diff("HEAD"):
                return {'success': False, 'error': 'No changes to commit'}
            
            # Commit changes
            commit = self.repo.index.commit(commit_message)
            
            # Push to remote
            origin = self.repo.remotes.origin
            origin.push()
            
            return {
                'success': True,
                'commit_hash': str(commit.hexsha[:7]),
                'message': f'Committed and pushed: {commit_message}'
            }
            
        except Exception as e:
            logger.error(f"Error committing and pushing: {e}")
            return {'success': False, 'error': str(e)}
    
    def pull_changes(self):
        """Pull latest changes from remote"""
        try:
            if not self.repo:
                raise Exception("No repository loaded")
            
            origin = self.repo.remotes.origin
            pull_info = origin.pull()
            
            return {
                'success': True,
                'message': 'Pull completed successfully',
                'changes': len(pull_info)
            }
            
        except Exception as e:
            logger.error(f"Error pulling changes: {e}")
            return {'success': False, 'error': str(e)}
    
    def get_file_tree(self):
        """Get repository file structure"""
        try:
            if not self.repo_path:
                return []
            
            files = []
            for root, dirs, filenames in os.walk(self.repo_path):
                # Skip .git directory
                dirs[:] = [d for d in dirs if d != '.git']
                
                for filename in filenames:
                    file_path = os.path.join(root, filename)
                    relative_path = os.path.relpath(file_path, self.repo_path)
                    
                    # Get file stats
                    stat = os.stat(file_path)
                    files.append({
                        'name': filename,
                        'path': relative_path,
                        'size': stat.st_size,
                        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat()
                    })
            
            return files
            
        except Exception as e:
            logger.error(f"Error getting file tree: {e}")
            return []
    
    def read_file(self, file_path):
        """Read file content"""
        try:
            full_path = os.path.join(self.repo_path, file_path)
            with open(full_path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            logger.error(f"Error reading file {file_path}: {e}")
            return None
    
    def write_file(self, file_path, content):
        """Write file content"""
        try:
            full_path = os.path.join(self.repo_path, file_path)
            
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        except Exception as e:
            logger.error(f"Error writing file {file_path}: {e}")
            return False

class LookerManager:
    def __init__(self):
        self.sdk = None
        self.connected = False
    
    def connect(self, base_url, client_id, client_secret):
        """Initialize Looker SDK connection"""
        try:
            config_settings = {
                'base_url': base_url,
                'client_id': client_id,
                'client_secret': client_secret,
                'verify_ssl': True
            }
            
            self.sdk = looker_sdk.init40(config_settings=config_settings)
            
            # Test connection
            me = self.sdk.me()
            self.connected = True
            
            return {
                'success': True,
                'user': me.display_name,
                'message': f'Connected as {me.display_name}'
            }
            
        except Exception as e:
            logger.error(f"Error connecting to Looker: {e}")
            self.connected = False
            return {'success': False, 'error': str(e)}
    
    def get_dashboards(self):
        """Get all dashboards"""
        try:
            if not self.connected:
                raise Exception("Not connected to Looker")
            
            dashboards = self.sdk.all_dashboards()
            
            dashboard_list = []
            for dash in dashboards:
                dashboard_list.append({
                    'id': dash.id,
                    'title': dash.title,
                    'description': dash.description,
                    'space_id': dash.space.id if dash.space else None,
                    'created_at': dash.created_at.isoformat() if dash.created_at else None,
                    'updated_at': dash.updated_at.isoformat() if dash.updated_at else None
                })
            
            return {'success': True, 'dashboards': dashboard_list}
            
        except Exception as e:
            logger.error(f"Error getting dashboards: {e}")
            return {'success': False, 'error': str(e)}
    
    def run_query(self, query_id, result_format='json'):
        """Run a query"""
        try:
            if not self.connected:
                raise Exception("Not connected to Looker")
            
            result = self.sdk.run_query(
                query_id=query_id,
                result_format=result_format
            )
            
            if result_format == 'json':
                data = json.loads(result)
                return {'success': True, 'data': data}
            else:
                return {'success': True, 'data': result}
            
        except Exception as e:
            logger.error(f"Error running query: {e}")
            return {'success': False, 'error': str(e)}

# Initialize managers
git_manager = GitManager(config.WORKSPACE_DIR)
looker_manager = LookerManager()

# API Routes

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/api/git/clone', methods=['POST'])
def clone_repository():
    """Clone a repository"""
    data = request.json
    repo_url = data.get('repo_url')
    token = data.get('token')
    
    if not repo_url:
        return jsonify({'success': False, 'error': 'Repository URL required'}), 400
    
    success = git_manager.clone_repository(repo_url, token)
    
    if success:
        file_tree = git_manager.get_file_tree()
        return jsonify({
            'success': True,
            'message': 'Repository cloned successfully',
            'file_tree': file_tree
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to clone repository'}), 500

@app.route('/api/git/fetch', methods=['POST'])
def git_fetch():
    """Fetch changes from remote"""
    result = git_manager.fetch_changes()
    return jsonify(result)

@app.route('/api/git/push', methods=['POST'])
def git_push():
    """Commit and push changes"""
    data = request.json
    commit_message = data.get('commit_message', 'Update from web interface')
    files_to_add = data.get('files')
    
    result = git_manager.commit_and_push(commit_message, files_to_add)
    return jsonify(result)

@app.route('/api/git/pull', methods=['POST'])
def git_pull():
    """Pull changes from remote"""
    result = git_manager.pull_changes()
    return jsonify(result)

@app.route('/api/files/tree', methods=['GET'])
def get_file_tree():
    """Get repository file tree"""
    file_tree = git_manager.get_file_tree()
    return jsonify({'success': True, 'files': file_tree})

@app.route('/api/files/read', methods=['POST'])
def read_file():
    """Read file content"""
    data = request.json
    file_path = data.get('file_path')
    
    if not file_path:
        return jsonify({'success': False, 'error': 'File path required'}), 400
    
    content = git_manager.read_file(file_path)
    
    if content is not None:
        return jsonify({'success': True, 'content': content})
    else:
        return jsonify({'success': False, 'error': 'Failed to read file'}), 500

@app.route('/api/files/write', methods=['POST'])
def write_file():
    """Write file content"""
    data = request.json
    file_path = data.get('file_path')
    content = data.get('content')
    
    if not file_path or content is None:
        return jsonify({'success': False, 'error': 'File path and content required'}), 400
    
    success = git_manager.write_file(file_path, content)
    
    if success:
        return jsonify({'success': True, 'message': 'File saved successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to save file'}), 500

@app.route('/api/files/upload', methods=['POST'])
def upload_file():
    """Upload file to repository"""
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'success': False, 'error': 'No file selected'}), 400
    
    # Check file size
    file.seek(0, 2)  # Seek to end
    file_size = file.tell()
    file.seek(0)     # Reset to beginning
    
    if file_size > config.MAX_FILE_SIZE:
        return jsonify({'success': False, 'error': 'File too large'}), 400
    
    # Save file
    content = file.read().decode('utf-8')
    success = git_manager.write_file(file.filename, content)
    
    if success:
        return jsonify({
            'success': True,
            'message': f'File {file.filename} uploaded successfully',
            'filename': file.filename,
            'size': file_size
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to save uploaded file'}), 500

@app.route('/api/looker/connect', methods=['POST'])
def looker_connect():
    """Connect to Looker"""
    data = request.json
    base_url = data.get('base_url')
    client_id = data.get('client_id')
    client_secret = data.get('client_secret')
    
    if not all([base_url, client_id, client_secret]):
        return jsonify({'success': False, 'error': 'All Looker credentials required'}), 400
    
    result = looker_manager.connect(base_url, client_id, client_secret)
    return jsonify(result)

@app.route('/api/looker/dashboards', methods=['GET'])
def get_looker_dashboards():
    """Get Looker dashboards"""
    result = looker_manager.get_dashboards()
    return jsonify(result)

@app.route('/api/looker/query', methods=['POST'])
def run_looker_query():
    """Run Looker query"""
    data = request.json
    query_id = data.get('query_id')
    result_format = data.get('result_format', 'json')
    
    if not query_id:
        return jsonify({'success': False, 'error': 'Query ID required'}), 400
    
    result = looker_manager.run_query(query_id, result_format)
    return jsonify(result)

@app.route('/api/execute/python', methods=['POST'])
def execute_python():
    """Execute Python script"""
    data = request.json
    script_content = data.get('script')
    script_name = data.get('filename', 'temp_script.py')
    
    if not script_content:
        return jsonify({'success': False, 'error': 'Script content required'}), 400
    
    try:
        # Create temporary script file
        script_path = os.path.join(git_manager.repo_path or config.WORKSPACE_DIR, script_name)
        
        with open(script_path, 'w') as f:
            f.write(script_content)
        
        # Execute script
        result = subprocess.run(
            ['python', script_path],
            capture_output=True,
            text=True,
            timeout=30,
            cwd=git_manager.repo_path or config.WORKSPACE_DIR
        )
        
        return jsonify({
            'success': True,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'return_code': result.returncode
        })
        
    except subprocess.TimeoutExpired:
        return jsonify({'success': False, 'error': 'Script execution timeout'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# Serve static files (for development)
@app.route('/')
def serve_frontend():
    """Serve the frontend HTML file"""
    return send_from_directory('../', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    """Serve static files"""
    return send_from_directory('../', path)

if __name__ == '__main__':
    # Create workspace directory
    os.makedirs(config.WORKSPACE_DIR, exist_ok=True)
    
    print("🚀 Starting GitHub Code Review Backend...")
    print(f"📁 Workspace directory: {config.WORKSPACE_DIR}")
    print(f"🌐 Server will run on: http://localhost:5000")
    print(f"📋 API endpoints available at: http://localhost:5000/api/")
    
    app.run(host='0.0.0.0', port=5000, debug=True)