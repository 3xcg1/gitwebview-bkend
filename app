<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Code Review & Preview Interface</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }

        .container {
            display: flex;
            height: 100vh;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            margin: 20px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .sidebar {
            width: 300px;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 20px;
            overflow-y: auto;
        }

        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: #f8f9fa;
        }

        .header {
            background: white;
            padding: 20px;
            border-bottom: 2px solid #e9ecef;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .github-config {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 15px;
            margin-bottom: 20px;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .input-group label {
            font-weight: 600;
            color: #495057;
            font-size: 0.9em;
        }

        .input-group input {
            padding: 10px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .input-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-primary {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }

        .btn-success {
            background: linear-gradient(45deg, #28a745, #20c997);
            color: white;
        }

        .btn-info {
            background: linear-gradient(45deg, #17a2b8, #6f42c1);
            color: white;
        }

        .btn-warning {
            background: linear-gradient(45deg, #ffc107, #fd7e14);
            color: white;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .content-area {
            flex: 1;
            display: flex;
            gap: 20px;
            padding: 20px;
            overflow: hidden;
        }

        .panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            border: 1px solid #e9ecef;
        }

        .preview-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .code-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .panel-header {
            background: linear-gradient(90deg, #495057, #6c757d);
            color: white;
            padding: 15px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .panel-content {
            flex: 1;
            overflow: auto;
            padding: 0;
        }

        .code-editor {
            width: 100%;
            height: 100%;
            border: none;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 14px;
            padding: 20px;
            background: #2d3748;
            color: #e2e8f0;
            resize: none;
        }

        .code-display {
            padding: 20px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 14px;
            line-height: 1.6;
            overflow: auto;
            background: #f8f9fa;
        }

        .file-tree {
            padding: 10px 0;
        }

        .file-item {
            padding: 8px 15px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            border-radius: 6px;
            margin: 2px 10px;
        }

        .file-item:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .file-item.active {
            background: rgba(102, 126, 234, 0.2);
            color: #667eea;
        }

        .status-bar {
            background: #343a40;
            color: white;
            padding: 10px 20px;
            font-size: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .status-indicator {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #28a745;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }

        .looker-panel {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: white;
            padding: 15px;
            margin: 10px 0;
            border-radius: 8px;
        }

        .looker-config {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-bottom: 15px;
        }

        .looker-config input {
            padding: 8px;
            border: none;
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            placeholder-color: rgba(255, 255, 255, 0.7);
        }

        .looker-config input::placeholder {
            color: rgba(255, 255, 255, 0.7);
        }

        .terminal {
            background: #1a1a1a;
            color: #00ff00;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            padding: 15px;
            height: 200px;
            overflow-y: auto;
            font-size: 12px;
            border-radius: 0 0 12px 12px;
        }

        .terminal-line {
            margin-bottom: 5px;
        }

        .diff-view {
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 12px;
            line-height: 1.4;
        }

        .diff-added {
            background: rgba(40, 167, 69, 0.1);
            color: #28a745;
            padding: 2px 5px;
            border-left: 3px solid #28a745;
        }

        .diff-removed {
            background: rgba(220, 53, 69, 0.1);
            color: #dc3545;
            padding: 2px 5px;
            border-left: 3px solid #dc3545;
        }

        .loading {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .hidden {
            display: none;
        }

        .sidebar-section {
            margin-bottom: 25px;
        }

        .sidebar-section h3 {
            margin-bottom: 15px;
            color: #ecf0f1;
            font-size: 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 8px;
        }

        .branch-selector {
            width: 100%;
            padding: 8px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            color: white;
            margin-bottom: 15px;
        }

        .branch-selector option {
            background: #2c3e50;
            color: white;
        }

        .commit-message {
            width: 100%;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            color: white;
            resize: vertical;
            height: 80px;
            font-family: inherit;
        }

        .upload-area {
            margin-bottom: 15px;
        }

        .upload-zone {
            border: 2px dashed rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }

        .upload-zone:hover {
            border-color: rgba(255, 255, 255, 0.6);
            background: rgba(255, 255, 255, 0.05);
        }

        .upload-zone.dragover {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.1);
            transform: scale(1.02);
        }

        .upload-zone i {
            font-size: 24px;
            margin-bottom: 10px;
            color: rgba(255, 255, 255, 0.8);
        }

        .upload-zone p {
            margin: 5px 0;
            color: rgba(255, 255, 255, 0.9);
            font-size: 14px;
        }

        .upload-text {
            font-size: 12px !important;
            color: rgba(255, 255, 255, 0.6) !important;
        }

        #fileInput {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }

        .uploaded-files {
            max-height: 200px;
            overflow-y: auto;
        }

        .uploaded-file-item {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 6px;
            padding: 8px 12px;
            margin: 5px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
            transition: all 0.2s ease;
        }

        .uploaded-file-item:hover {
            background: rgba(255, 255, 255, 0.15);
        }

        .file-info {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;
            min-width: 0;
        }

        .file-name {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: rgba(255, 255, 255, 0.9);
        }

        .file-size {
            color: rgba(255, 255, 255, 0.6);
            font-size: 10px;
        }

        .file-actions {
            display: flex;
            gap: 5px;
        }

        .file-action-btn {
            background: none;
            border: none;
            color: rgba(255, 255, 255, 0.7);
            cursor: pointer;
            padding: 4px;
            border-radius: 3px;
            transition: all 0.2s ease;
            font-size: 12px;
        }

        .file-action-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .file-action-btn.add-btn {
            color: #28a745;
        }

        .file-action-btn.add-btn:hover {
            background: rgba(40, 167, 69, 0.2);
        }

        .file-action-btn.remove-btn {
            color: #dc3545;
        }

        .file-action-btn.remove-btn:hover {
            background: rgba(220, 53, 69, 0.2);
        }

        .upload-progress {
            width: 100%;
            height: 4px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 2px;
            margin-top: 5px;
            overflow: hidden;
        }

        .upload-progress-bar {
            height: 100%;
            background: linear-gradient(45deg, #28a745, #20c997);
            width: 0%;
            transition: width 0.3s ease;
            border-radius: 2px;
        }

        .file-type-icon {
            width: 16px;
            text-align: center;
        }

        .upload-status {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 10px;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.8);
        }

        .upload-status.success {
            color: #28a745;
        }

        .upload-status.error {
            color: #dc3545;
        }

        @media (max-width: 1200px) {
            .github-config {
                grid-template-columns: 1fr 1fr;
            }
            
            .content-area {
                flex-direction: column;
            }
            
            .sidebar {
                width: 250px;
            }
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                margin: 10px;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
            }
            
            .github-config {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <div class="sidebar-section">
                <h3><i class="fab fa-github"></i> Repository</h3>
                <select class="branch-selector" id="branchSelector">
                    <option value="main">main</option>
                    <option value="develop">develop</option>
                    <option value="feature/new-feature">feature/new-feature</option>
                </select>
                <div class="file-tree" id="fileTree">
                    <div class="file-item active" data-file="app.py">
                        <i class="fab fa-python"></i> app.py
                    </div>
                    <div class="file-item" data-file="config.json">
                        <i class="fas fa-cog"></i> config.json
                    </div>
                    <div class="file-item" data-file="looker_integration.py">
                        <i class="fas fa-chart-bar"></i> looker_integration.py
                    </div>
                    <div class="file-item" data-file="requirements.txt">
                        <i class="fas fa-list"></i> requirements.txt
                    </div>
                    <div class="file-item" data-file="README.md">
                        <i class="fab fa-markdown"></i> README.md
                    </div>
                </div>
            </div>

            <div class="sidebar-section">
                <h3><i class="fas fa-upload"></i> File Upload</h3>
                <div class="upload-area" id="uploadArea">
                    <div class="upload-zone">
                        <i class="fas fa-cloud-upload-alt"></i>
                        <p>Drag & drop files here</p>
                        <p class="upload-text">or click to browse</p>
                        <input type="file" id="fileInput" multiple accept=".py,.js,.json,.md,.txt,.yml,.yaml,.css,.html,.sql,.xml,.csv">
                    </div>
                </div>
                <div class="uploaded-files" id="uploadedFiles"></div>
            </div>

            <div class="sidebar-section">
                <h3><i class="fas fa-code-branch"></i> Commit</h3>
                <textarea class="commit-message" id="commitMessage" placeholder="Enter commit message..."></textarea>
            </div>

            <div class="looker-panel">
                <h4><i class="fas fa-chart-line"></i> Looker SDK</h4>
                <div class="looker-config">
                    <input type="text" id="lookerHost" placeholder="Looker Host">
                    <input type="text" id="lookerPort" placeholder="Port">
                    <input type="text" id="lookerClientId" placeholder="Client ID">
                    <input type="password" id="lookerClientSecret" placeholder="Client Secret">
                </div>
                <button class="btn btn-info" onclick="testLookerConnection()">
                    <i class="fas fa-plug"></i> Test Connection
                </button>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <h1><i class="fab fa-github"></i> GitHub Code Review & Preview Interface</h1>
                <div class="github-config">
                    <div class="input-group">
                        <label>Repository URL</label>
                        <input type="text" id="repoUrl" placeholder="https://github.com/user/repo.git" value="https://github.com/example/sample-repo.git">
                    </div>
                    <div class="input-group">
                        <label>GitHub Token</label>
                        <input type="password" id="githubToken" placeholder="ghp_xxxxxxxxxxxxx">
                    </div>
                    <div class="input-group">
                        <label>Branch</label>
                        <input type="text" id="branchName" placeholder="main" value="main">
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-info" onclick="gitFetch()">
                        <i class="fas fa-download"></i> Git Fetch
                    </button>
                    <button class="btn btn-warning" onclick="pullAndRun()">
                        <i class="fas fa-play"></i> Pull & Run
                    </button>
                    <button class="btn btn-success" onclick="gitPush()">
                        <i class="fas fa-upload"></i> Git Push
                    </button>
                    <button class="btn btn-primary" onclick="runLookerScript()">
                        <i class="fas fa-chart-bar"></i> Run Looker SDK
                    </button>
                    <button class="btn btn-info" onclick="addAllUploadedFiles()">
                        <i class="fas fa-plus-circle"></i> Add All Uploads
                    </button>
                </div>
            </div>

            <div class="content-area">
                <div class="preview-panel panel">
                    <div class="panel-header">
                        <i class="fas fa-eye"></i> Code Preview & Review
                    </div>
                    <div class="panel-content">
                        <div class="code-display" id="codePreview">
                            <pre><code class="language-python"># Sample Python application with Looker SDK integration
import looker_sdk
from typing import Dict, List, Optional
import json
import os

class LookerManager:
    def __init__(self, base_url: str, client_id: str, client_secret: str):
        """Initialize Looker SDK connection"""
        self.sdk = looker_sdk.init40(
            config_settings={
                'base_url': base_url,
                'client_id': client_id,
                'client_secret': client_secret
            }
        )
    
    def get_dashboards(self) -> List[Dict]:
        """Fetch all dashboards from Looker"""
        try:
            dashboards = self.sdk.all_dashboards()
            return [
                {
                    'id': dash.id,
                    'title': dash.title,
                    'description': dash.description
                }
                for dash in dashboards
            ]
        except Exception as e:
            print(f"Error fetching dashboards: {e}")
            return []
    
    def run_query(self, query_id: str) -> Dict:
        """Execute a query and return results"""
        try:
            result = self.sdk.run_query(
                query_id=query_id,
                result_format='json'
            )
            return json.loads(result)
        except Exception as e:
            print(f"Error running query: {e}")
            return {}

def main():
    # Initialize Looker connection
    looker = LookerManager(
        base_url=os.getenv('LOOKER_BASE_URL'),
        client_id=os.getenv('LOOKER_CLIENT_ID'),
        client_secret=os.getenv('LOOKER_CLIENT_SECRET')
    )
    
    # Get dashboards
    dashboards = looker.get_dashboards()
    print(f"Found {len(dashboards)} dashboards")
    
    for dashboard in dashboards[:5]:  # Show first 5
        print(f"- {dashboard['title']}")

if __name__ == "__main__":
    main()</code></pre>
                        </div>
                    </div>
                </div>

                <div class="code-panel panel">
                    <div class="panel-header">
                        <i class="fas fa-code"></i> Code Editor
                    </div>
                    <div class="panel-content">
                        <textarea class="code-editor" id="codeEditor" placeholder="Write or edit your code here...">
# Sample Python application with Looker SDK integration
import looker_sdk
from typing import Dict, List, Optional
import json
import os

class LookerManager:
    def __init__(self, base_url: str, client_id: str, client_secret: str):
        """Initialize Looker SDK connection"""
        self.sdk = looker_sdk.init40(
            config_settings={
                'base_url': base_url,
                'client_id': client_id,
                'client_secret': client_secret
            }
        )
    
    def get_dashboards(self) -> List[Dict]:
        """Fetch all dashboards from Looker"""
        try:
            dashboards = self.sdk.all_dashboards()
            return [
                {
                    'id': dash.id,
                    'title': dash.title,
                    'description': dash.description
                }
                for dash in dashboards
            ]
        except Exception as e:
            print(f"Error fetching dashboards: {e}")
            return []
    
    def run_query(self, query_id: str) -> Dict:
        """Execute a query and return results"""
        try:
            result = self.sdk.run_query(
                query_id=query_id,
                result_format='json'
            )
            return json.loads(result)
        except Exception as e:
            print(f"Error running query: {e}")
            return {}

def main():
    # Initialize Looker connection
    looker = LookerManager(
        base_url=os.getenv('LOOKER_BASE_URL'),
        client_id=os.getenv('LOOKER_CLIENT_ID'),
        client_secret=os.getenv('LOOKER_CLIENT_SECRET')
    )
    
    # Get dashboards
    dashboards = looker.get_dashboards()
    print(f"Found {len(dashboards)} dashboards")
    
    for dashboard in dashboards[:5]:  # Show first 5
        print(f"- {dashboard['title']}")

if __name__ == "__main__":
    main()
                        </textarea>
                    </div>
                    <div class="terminal" id="terminal">
                        <div class="terminal-line">$ Terminal ready...</div>
                        <div class="terminal-line">$ Looker SDK environment initialized</div>
                        <div class="terminal-line">$ Ready for GitHub operations</div>
                    </div>
                </div>
            </div>

            <div class="status-bar">
                <div class="status-indicator">
                    <div class="status-dot"></div>
                    <span id="statusText">Ready - Connected to GitHub</span>
                </div>
                <div id="currentFile">app.py</div>
            </div>
        </div>
    </div>

    <script>
        // Global state management
        let currentFile = 'app.py';
        let fileContents = {
            'app.py': `# Sample Python application with Looker SDK integration
import looker_sdk
from typing import Dict, List, Optional
import json
import os

class LookerManager:
    def __init__(self, base_url: str, client_id: str, client_secret: str):
        """Initialize Looker SDK connection"""
        self.sdk = looker_sdk.init40(
            config_settings={
                'base_url': base_url,
                'client_id': client_id,
                'client_secret': client_secret
            }
        )
    
    def get_dashboards(self) -> List[Dict]:
        """Fetch all dashboards from Looker"""
        try:
            dashboards = self.sdk.all_dashboards()
            return [
                {
                    'id': dash.id,
                    'title': dash.title,
                    'description': dash.description
                }
                for dash in dashboards
            ]
        except Exception as e:
            print(f"Error fetching dashboards: {e}")
            return []
    
    def run_query(self, query_id: str) -> Dict:
        """Execute a query and return results"""
        try:
            result = self.sdk.run_query(
                query_id=query_id,
                result_format='json'
            )
            return json.loads(result)
        except Exception as e:
            print(f"Error running query: {e}")
            return {}

def main():
    # Initialize Looker connection
    looker = LookerManager(
        base_url=os.getenv('LOOKER_BASE_URL'),
        client_id=os.getenv('LOOKER_CLIENT_ID'),
        client_secret=os.getenv('LOOKER_CLIENT_SECRET')
    )
    
    # Get dashboards
    dashboards = looker.get_dashboards()
    print(f"Found {len(dashboards)} dashboards")
    
    for dashboard in dashboards[:5]:  # Show first 5
        print(f"- {dashboard['title']}")

if __name__ == "__main__":
    main()`,
            'config.json': `{
    "looker": {
        "base_url": "https://your-looker-instance.looker.com",
        "api_version": "4.0"
    },
    "github": {
        "repository": "example/sample-repo",
        "default_branch": "main"
    },
    "environment": {
        "python_version": "3.9+",
        "dependencies": ["looker-sdk", "requests", "python-dotenv"]
    }
}`,
            'looker_integration.py': `"""
Advanced Looker SDK Integration Module
Provides comprehensive Looker API functionality
"""

import looker_sdk
import os
from typing import Dict, List, Optional, Any
import json
import pandas as pd

class AdvancedLookerManager:
    def __init__(self, config_file: str = None):
        """Initialize with config file or environment variables"""
        if config_file:
            self._load_from_config(config_file)
        else:
            self._load_from_env()
        
        self.sdk = looker_sdk.init40(config_settings=self.config)
    
    def _load_from_config(self, config_file: str):
        """Load configuration from JSON file"""
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        self.config = {
            'base_url': config['looker']['base_url'],
            'client_id': config['looker']['client_id'],
            'client_secret': config['looker']['client_secret']
        }
    
    def _load_from_env(self):
        """Load configuration from environment variables"""
        self.config = {
            'base_url': os.getenv('LOOKER_BASE_URL'),
            'client_id': os.getenv('LOOKER_CLIENT_ID'),
            'client_secret': os.getenv('LOOKER_CLIENT_SECRET')
        }
    
    def get_all_dashboards(self) -> List[Dict[str, Any]]:
        """Retrieve all dashboards with detailed information"""
        try:
            dashboards = self.sdk.all_dashboards()
            return [
                {
                    'id': dash.id,
                    'title': dash.title,
                    'description': dash.description,
                    'space_id': dash.space.id if dash.space else None,
                    'created_at': dash.created_at,
                    'updated_at': dash.updated_at
                }
                for dash in dashboards
            ]
        except Exception as e:
            print(f"Error fetching dashboards: {e}")
            return []
    
    def export_dashboard_to_pdf(self, dashboard_id: str, output_path: str):
        """Export dashboard as PDF"""
        try:
            task = self.sdk.create_dashboard_render_task(
                dashboard_id=dashboard_id,
                result_format='pdf',
                width=1920,
                height=1080
            )
            
            # Poll for completion
            while task.status not in ['complete', 'error']:
                task = self.sdk.render_task(task.id)
            
            if task.status == 'complete':
                result = self.sdk.render_task_results(task.id)
                with open(output_path, 'wb') as f:
                    f.write(result)
                print(f"Dashboard exported to {output_path}")
            else:
                print(f"Export failed: {task.status_detail}")
                
        except Exception as e:
            print(f"Error exporting dashboard: {e}")
    
    def run_sql_query(self, sql: str, connection: str) -> pd.DataFrame:
        """Execute SQL query and return as DataFrame"""
        try:
            query_config = {
                'model': 'system__activity',
                'explore': 'query',
                'fields': ['*'],
                'sql': sql,
                'connection_name': connection
            }
            
            query = self.sdk.create_sql_query(query_config)
            result = self.sdk.run_sql_query(
                slug=query.slug,
                result_format='json'
            )
            
            data = json.loads(result)
            return pd.DataFrame(data)
            
        except Exception as e:
            print(f"Error running SQL query: {e}")
            return pd.DataFrame()
    
    def create_look(self, query_id: str, title: str, space_id: str) -> Dict:
        """Create a new Look from a query"""
        try:
            look_config = {
                'title': title,
                'query_id': query_id,
                'space_id': space_id
            }
            
            look = self.sdk.create_look(look_config)
            return {
                'id': look.id,
                'title': look.title,
                'url': f"{self.config['base_url']}/looks/{look.id}"
            }
            
        except Exception as e:
            print(f"Error creating look: {e}")
            return {}
    
    def get_user_activity(self, days: int = 30) -> List[Dict]:
        """Get user activity for the last N days"""
        try:
            # This would typically use the system activity explore
            # Implementation depends on your Looker setup
            query_config = {
                'model': 'system__activity',
                'explore': 'history',
                'fields': ['history.created_date', 'user.name', 'history.status'],
                'filters': {
                    'history.created_date': f'{days} days ago for {days} days'
                }
            }
            
            query = self.sdk.create_query(query_config)
            result = self.sdk.run_query(
                query_id=query.id,
                result_format='json'
            )
            
            return json.loads(result)
            
        except Exception as e:
            print(f"Error fetching user activity: {e}")
            return []

# Example usage and testing functions
def test_looker_connection():
    """Test basic Looker connectivity"""
    try:
        looker = AdvancedLookerManager()
        me = looker.sdk.me()
        print(f"Successfully connected as: {me.display_name}")
        return True
    except Exception as e:
        print(f"Connection failed: {e}")
        return False

def generate_dashboard_report():
    """Generate comprehensive dashboard report"""
    looker = AdvancedLookerManager()
    dashboards = looker.get_all_dashboards()
    
    print(f"\\n=== Dashboard Report ===")
    print(f"Total Dashboards: {len(dashboards)}")
    
    for dash in dashboards[:10]:  # Show first 10
        print(f"- {dash['title']} (ID: {dash['id']})")
    
    return dashboards

if __name__ == "__main__":
    if test_looker_connection():
        generate_dashboard_report()`,
            'requirements.txt': `# Core dependencies
looker-sdk>=22.20.0
pandas>=1.5.0
requests>=2.28.0
python-dotenv>=0.19.0

# Development dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=5.0.0

# GitHub integration
PyGithub>=1.58.0
gitpython>=3.1.0

# Additional utilities
pyyaml>=6.0
click>=8.0.0
rich>=12.0.0`,
            'README.md': `# GitHub Code Review & Preview Interface

A comprehensive web-based interface for reviewing, previewing, and managing code with full GitHub integration and Looker SDK support.

## Features

### 🔍 Code Review & Preview
- **Real-time code preview** with syntax highlighting
- **Side-by-side diff view** for change comparison
- **Interactive file tree** navigation
- **Multi-language support** (Python, JavaScript, JSON, Markdown, etc.)

### 🐙 GitHub Integration
- **Git Fetch**: Pull latest changes from remote repository
- **Git Push**: Commit and push changes to GitHub
- **Branch Management**: Switch between different branches
- **Pull & Run**: Download and execute code directly from GitHub

### 📊 Looker SDK Integration
- **Full Looker SDK support** for data analytics
- **Dashboard management** and export capabilities
- **SQL query execution** with pandas integration
- **User activity tracking** and reporting
- **Look creation** and management

## Setup Instructions

### Prerequisites
- Python 3.9 or higher
- GitHub account with repository access
- Looker instance with API credentials

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/your-username/github-code-reviewer.git
   cd github-code-reviewer
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

3. **Environment Configuration**
   Create a \`.env\` file:
   \`\`\`env
   # GitHub Configuration
   GITHUB_TOKEN=your_github_token_here
   GITHUB_REPO_URL=https://github.com/user/repo.git

   # Looker Configuration
   LOOKER_BASE_URL=https://your-instance.looker.com
   LOOKER_CLIENT_ID=your_client_id
   LOOKER_CLIENT_SECRET=your_client_secret
   \`\`\`

### Usage

1. **Open the interface**
   - Open \`index.html\` in your web browser
   - Or serve it using a local web server

2. **Configure GitHub**
   - Enter your repository URL
   - Add your GitHub personal access token
   - Select the target branch

3. **Configure Looker**
   - Enter your Looker instance details
   - Test the connection
   - Start using Looker SDK features

## Features in Detail

### Code Preview Panel
- **Syntax Highlighting**: Powered by Prism.js
- **File Navigation**: Click files in the sidebar to view
- **Live Updates**: Changes reflect immediately

### Git Operations
- **Fetch**: \`git fetch origin\`
- **Push**: \`git add . && git commit -m "message" && git push\`
- **Pull & Run**: \`git pull && python app.py\`

### Looker SDK Capabilities
- Dashboard listing and management
- PDF export functionality
- SQL query execution
- User activity monitoring
- Look creation and sharing

## API Reference

### LookerManager Class
\`\`\`python
from looker_integration import AdvancedLookerManager

# Initialize
looker = AdvancedLookerManager()

# Get all dashboards
dashboards = looker.get_all_dashboards()

# Export dashboard
looker.export_dashboard_to_pdf('123', 'output.pdf')

# Run SQL query
df = looker.run_sql_query('SELECT * FROM users', 'my_connection')
\`\`\`

## Security Considerations

- **Never commit sensitive credentials** to version control
- **Use environment variables** for all API keys and tokens
- **Implement proper access controls** in production
- **Regularly rotate API keys** and tokens

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Create an issue on GitHub
- Check the documentation
- Review the example code

---

**Built with ❤️ for modern development workflows**`
        };
        let gitStatus = 'ready';
        let uploadedFiles = new Map(); // Store uploaded file contents
        let pendingUploads = new Set(); // Track files pending integration

        // Initialize the application
        document.addEventListener('DOMContentLoaded', function() {
            initializeFileTree();
            initializeCodeEditor();
            initializeUploadArea();
            updateStatusIndicator('Ready - Connected to GitHub');
        });

        // File tree navigation
        function initializeFileTree() {
            const fileItems = document.querySelectorAll('.file-item');
            fileItems.forEach(item => {
                item.addEventListener('click', function() {
                    const fileName = this.getAttribute('data-file');
                    selectFile(fileName);
                });
            });
        }

        function selectFile(fileName) {
            // Update active file
            document.querySelectorAll('.file-item').forEach(item => {
                item.classList.remove('active');
            });
            document.querySelector(`[data-file="${fileName}"]`).classList.add('active');
            
            currentFile = fileName;
            document.getElementById('currentFile').textContent = fileName;
            
            // Load file content
            const content = fileContents[fileName] || '// File content not available';
            document.getElementById('codeEditor').value = content;
            updatePreview(content, fileName);
        }

        // Code editor functionality
        function initializeCodeEditor() {
            const editor = document.getElementById('codeEditor');
            editor.addEventListener('input', function() {
                const content = this.value;
                fileContents[currentFile] = content;
                updatePreview(content, currentFile);
            });
        }

        function updatePreview(content, fileName) {
            const preview = document.getElementById('codePreview');
            const language = getLanguageFromFileName(fileName);
            
            preview.innerHTML = `<pre><code class="language-${language}">${escapeHtml(content)}</code></pre>`;
            
            // Re-highlight the code
            if (window.Prism) {
                Prism.highlightAll();
            }
        }

        function getLanguageFromFileName(fileName) {
            const extension = fileName.split('.').pop();
            const languageMap = {
                'py': 'python',
                'js': 'javascript',
                'json': 'json',
                'md': 'markdown',
                'txt': 'text',
                'yml': 'yaml',
                'yaml': 'yaml'
            };
            return languageMap[extension] || 'text';
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        // File upload functionality
        function initializeUploadArea() {
            const uploadArea = document.getElementById('uploadArea');
            const uploadZone = uploadArea.querySelector('.upload-zone');
            const fileInput = document.getElementById('fileInput');

            // Click to browse files
            uploadZone.addEventListener('click', () => {
                fileInput.click();
            });

            // Drag and drop handlers
            uploadZone.addEventListener('dragover', (e) => {
                e.preventDefault();
                uploadZone.classList.add('dragover');
            });

            uploadZone.addEventListener('dragleave', () => {
                uploadZone.classList.remove('dragover');
            });

            uploadZone.addEventListener('drop', (e) => {
                e.preventDefault();
                uploadZone.classList.remove('dragover');
                const files = Array.from(e.dataTransfer.files);
                handleFileUpload(files);
            });

            // File input change handler
            fileInput.addEventListener('change', (e) => {
                const files = Array.from(e.target.files);
                handleFileUpload(files);
                e.target.value = ''; // Reset input
            });
        }

        async function handleFileUpload(files) {
            const validExtensions = ['.py', '.js', '.json', '.md', '.txt', '.yml', '.yaml', '.css', '.html', '.sql', '.xml', '.csv'];
            
            for (const file of files) {
                const extension = '.' + file.name.split('.').pop().toLowerCase();
                
                if (!validExtensions.includes(extension)) {
                    showUploadStatus(`Skipped ${file.name} - unsupported file type`, 'error');
                    continue;
                }

                if (file.size > 5 * 1024 * 1024) { // 5MB limit
                    showUploadStatus(`Skipped ${file.name} - file too large (max 5MB)`, 'error');
                    continue;
                }

                try {
                    const content = await readFileContent(file);
                    uploadedFiles.set(file.name, {
                        content: content,
                        size: file.size,
                        type: file.type,
                        lastModified: file.lastModified
                    });
                    
                    pendingUploads.add(file.name);
                    addUploadedFileToUI(file.name, file.size);
                    showUploadStatus(`✓ ${file.name} uploaded successfully`, 'success');
                    
                } catch (error) {
                    showUploadStatus(`✗ Failed to upload ${file.name}`, 'error');
                }
            }
        }

        function readFileContent(file) {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = (e) => resolve(e.target.result);
                reader.onerror = () => reject(new Error('Failed to read file'));
                reader.readAsText(file);
            });
        }

        function addUploadedFileToUI(fileName, fileSize) {
            const uploadedFilesContainer = document.getElementById('uploadedFiles');
            
            // Remove existing item if it exists
            const existingItem = uploadedFilesContainer.querySelector(`[data-filename="${fileName}"]`);
            if (existingItem) {
                existingItem.remove();
            }

            const fileItem = document.createElement('div');
            fileItem.className = 'uploaded-file-item';
            fileItem.setAttribute('data-filename', fileName);
            
            const fileIcon = getFileIcon(fileName);
            const formattedSize = formatFileSize(fileSize);
            const isPending = pendingUploads.has(fileName);
            
            fileItem.innerHTML = `
                <div class="file-info">
                    <i class="file-type-icon ${fileIcon}"></i>
                    <div>
                        <div class="file-name" title="${fileName}">${fileName}</div>
                        <div class="file-size">${formattedSize}</div>
                    </div>
                </div>
                <div class="file-actions">
                    ${isPending ? 
                        `<button class="file-action-btn add-btn" onclick="addFileToProject('${fileName}')" title="Add to project">
                            <i class="fas fa-plus"></i>
                        </button>` : 
                        `<button class="file-action-btn" onclick="viewUploadedFile('${fileName}')" title="View file">
                            <i class="fas fa-eye"></i>
                        </button>`
                    }
                    <button class="file-action-btn remove-btn" onclick="removeUploadedFile('${fileName}')" title="Remove file">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            
            uploadedFilesContainer.appendChild(fileItem);
        }

        function getFileIcon(fileName) {
            const extension = fileName.split('.').pop().toLowerCase();
            const iconMap = {
                'py': 'fab fa-python',
                'js': 'fab fa-js-square',
                'json': 'fas fa-code',
                'md': 'fab fa-markdown',
                'txt': 'fas fa-file-alt',
                'yml': 'fas fa-cog',
                'yaml': 'fas fa-cog',
                'css': 'fab fa-css3-alt',
                'html': 'fab fa-html5',
                'sql': 'fas fa-database',
                'xml': 'fas fa-code',
                'csv': 'fas fa-table'
            };
            return iconMap[extension] || 'fas fa-file';
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function showUploadStatus(message, type = 'info') {
            const uploadArea = document.getElementById('uploadArea');
            
            // Remove existing status
            const existingStatus = uploadArea.querySelector('.upload-status');
            if (existingStatus) {
                existingStatus.remove();
            }
            
            const statusElement = document.createElement('div');
            statusElement.className = `upload-status ${type}`;
            statusElement.innerHTML = `<i class="fas fa-info-circle"></i> ${message}`;
            
            uploadArea.appendChild(statusElement);
            
            // Auto-remove after 3 seconds
            setTimeout(() => {
                if (statusElement.parentNode) {
                    statusElement.remove();
                }
            }, 3000);
        }

        function addFileToProject(fileName) {
            if (!uploadedFiles.has(fileName)) {
                alert('File not found in uploads');
                return;
            }

            const fileData = uploadedFiles.get(fileName);
            
            // Add to file contents
            fileContents[fileName] = fileData.content;
            
            // Add to file tree
            addFileToTree(fileName);
            
            // Remove from pending uploads
            pendingUploads.delete(fileName);
            
            // Update UI
            addUploadedFileToUI(fileName, fileData.size);
            
            // Select the newly added file
            selectFile(fileName);
            
            addTerminalOutput(`✓ Added ${fileName} to project`);
            showUploadStatus(`${fileName} added to project successfully`, 'success');
        }

        function addFileToTree(fileName) {
            const fileTree = document.getElementById('fileTree');
            
            // Check if file already exists in tree
            const existingFile = fileTree.querySelector(`[data-file="${fileName}"]`);
            if (existingFile) {
                return; // File already in tree
            }
            
            const fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            fileItem.setAttribute('data-file', fileName);
            
            const fileIcon = getFileIcon(fileName);
            fileItem.innerHTML = `<i class="${fileIcon}"></i> ${fileName}`;
            
            // Add click handler
            fileItem.addEventListener('click', function() {
                selectFile(fileName);
            });
            
            fileTree.appendChild(fileItem);
        }

        function viewUploadedFile(fileName) {
            if (!uploadedFiles.has(fileName)) {
                alert('File not found in uploads');
                return;
            }

            const fileData = uploadedFiles.get(fileName);
            
            // Create a temporary file entry for viewing
            const originalContent = fileContents[currentFile];
            const originalFile = currentFile;
            
            // Temporarily show the uploaded file
            fileContents[fileName] = fileData.content;
            selectFile(fileName);
            
            addTerminalOutput(`Viewing uploaded file: ${fileName}`);
        }

        function removeUploadedFile(fileName) {
            if (confirm(`Are you sure you want to remove ${fileName}?`)) {
                uploadedFiles.delete(fileName);
                pendingUploads.delete(fileName);
                
                // Remove from UI
                const fileItem = document.querySelector(`[data-filename="${fileName}"]`);
                if (fileItem) {
                    fileItem.remove();
                }
                
                // Remove from project if it was added
                if (fileContents.hasOwnProperty(fileName)) {
                    delete fileContents[fileName];
                    
                    // Remove from file tree
                    const treeItem = document.querySelector(`[data-file="${fileName}"]`);
                    if (treeItem) {
                        treeItem.remove();
                    }
                    
                    // If currently viewing this file, switch to another
                    if (currentFile === fileName) {
                        selectFile('app.py');
                    }
                }
                
                addTerminalOutput(`✗ Removed ${fileName}`);
                showUploadStatus(`${fileName} removed`, 'info');
            }
        }

        function addAllUploadedFiles() {
            if (pendingUploads.size === 0) {
                alert('No pending uploads to add');
                return;
            }

            const filesToAdd = Array.from(pendingUploads);
            let addedCount = 0;

            filesToAdd.forEach(fileName => {
                addFileToProject(fileName);
                addedCount++;
            });

            addTerminalOutput(`✓ Added ${addedCount} uploaded files to project`);
            showUploadStatus(`${addedCount} files added to project`, 'success');
            updateStatusIndicator(`Added ${addedCount} files to project`, 'success');
        }

        // Git operations
        async function gitFetch() {
            updateStatusIndicator('Fetching from GitHub...', 'loading');
            addTerminalOutput('$ git fetch origin');
            
            try {
                // Simulate GitHub API call
                await simulateGitOperation('fetch');
                addTerminalOutput('✓ Successfully fetched latest changes');
                addTerminalOutput(`✓ Updated ${Object.keys(fileContents).length} files`);
                updateStatusIndicator('Fetch completed successfully', 'success');
            } catch (error) {
                addTerminalOutput(`✗ Error: ${error.message}`);
                updateStatusIndicator('Fetch failed', 'error');
            }
        }

        async function gitPush() {
            const commitMessage = document.getElementById('commitMessage').value;
            if (!commitMessage.trim()) {
                alert('Please enter a commit message');
                return;
            }

            updateStatusIndicator('Pushing to GitHub...', 'loading');
            addTerminalOutput(`$ git add .`);
            addTerminalOutput(`$ git commit -m "${commitMessage}"`);
            addTerminalOutput(`$ git push origin ${document.getElementById('branchName').value}`);
            
            try {
                await simulateGitOperation('push');
                addTerminalOutput('✓ Changes committed and pushed successfully');
                updateStatusIndicator('Push completed successfully', 'success');
                document.getElementById('commitMessage').value = '';
            } catch (error) {
                addTerminalOutput(`✗ Error: ${error.message}`);
                updateStatusIndicator('Push failed', 'error');
            }
        }

        async function pullAndRun() {
            updateStatusIndicator('Pulling and running code...', 'loading');
            addTerminalOutput('$ git pull origin main');
            addTerminalOutput('$ python app.py');
            
            try {
                await simulateGitOperation('pull');
                await simulateCodeExecution();
                addTerminalOutput('✓ Code pulled and executed successfully');
                updateStatusIndicator('Pull & Run completed', 'success');
            } catch (error) {
                addTerminalOutput(`✗ Error: ${error.message}`);
                updateStatusIndicator('Pull & Run failed', 'error');
            }
        }

        // Looker SDK integration
        async function testLookerConnection() {
            const host = document.getElementById('lookerHost').value;
            const clientId = document.getElementById('lookerClientId').value;
            
            if (!host || !clientId) {
                alert('Please enter Looker host and client ID');
                return;
            }

            updateStatusIndicator('Testing Looker connection...', 'loading');
            addTerminalOutput('$ Testing Looker SDK connection...');
            
            try {
                await simulateLookerOperation('test_connection');
                addTerminalOutput('✓ Looker SDK connection successful');
                addTerminalOutput('✓ Authentication validated');
                addTerminalOutput('✓ API endpoints accessible');
                updateStatusIndicator('Looker connected successfully', 'success');
            } catch (error) {
                addTerminalOutput(`✗ Looker connection failed: ${error.message}`);
                updateStatusIndicator('Looker connection failed', 'error');
            }
        }

        async function runLookerScript() {
            updateStatusIndicator('Running Looker SDK script...', 'loading');
            addTerminalOutput('$ python looker_integration.py');
            addTerminalOutput('Initializing Looker SDK...');
            
            try {
                await simulateLookerOperation('run_script');
                addTerminalOutput('✓ Connected to Looker instance');
                addTerminalOutput('✓ Retrieved 15 dashboards');
                addTerminalOutput('✓ Exported 3 reports to PDF');
                addTerminalOutput('✓ Query execution completed');
                updateStatusIndicator('Looker script completed successfully', 'success');
            } catch (error) {
                addTerminalOutput(`✗ Script execution failed: ${error.message}`);
                updateStatusIndicator('Looker script failed', 'error');
            }
        }

        // Utility functions
        function updateStatusIndicator(message, type = 'ready') {
            const statusText = document.getElementById('statusText');
            const statusDot = document.querySelector('.status-dot');
            
            statusText.textContent = message;
            
            statusDot.className = 'status-dot';
            if (type === 'loading') {
                statusDot.style.background = '#ffc107';
                statusDot.style.animation = 'pulse 0.5s infinite';
            } else if (type === 'success') {
                statusDot.style.background = '#28a745';
                statusDot.style.animation = 'pulse 2s infinite';
            } else if (type === 'error') {
                statusDot.style.background = '#dc3545';
                statusDot.style.animation = 'pulse 1s infinite';
            } else {
                statusDot.style.background = '#28a745';
                statusDot.style.animation = 'pulse 2s infinite';
            }
        }

        function addTerminalOutput(message) {
            const terminal = document.getElementById('terminal');
            const line = document.createElement('div');
            line.className = 'terminal-line';
            line.textContent = message;
            terminal.appendChild(line);
            terminal.scrollTop = terminal.scrollHeight;
        }

        // Simulation functions (replace with actual API calls)
        async function simulateGitOperation(operation) {
            return new Promise((resolve, reject) => {
                setTimeout(() => {
                    if (Math.random() > 0.1) { // 90% success rate
                        resolve(`${operation} completed`);
                    } else {
                        reject(new Error(`${operation} operation failed`));
                    }
                }, 2000);
            });
        }

        async function simulateCodeExecution() {
            return new Promise((resolve) => {
                setTimeout(() => {
                    addTerminalOutput('Installing dependencies...');
                    setTimeout(() => {
                        addTerminalOutput('Starting application...');
                        setTimeout(() => {
                            addTerminalOutput('Application running on port 8000');
                            resolve();
                        }, 1000);
                    }, 1000);
                }, 1000);
            });
        }

        async function simulateLookerOperation(operation) {
            return new Promise((resolve, reject) => {
                setTimeout(() => {
                    if (Math.random() > 0.05) { // 95% success rate
                        resolve(`${operation} completed`);
                    } else {
                        reject(new Error(`Looker ${operation} failed`));
                    }
                }, 1500);
            });
        }

        // Branch selector functionality
        document.getElementById('branchSelector').addEventListener('change', function() {
            const branch = this.value;
            document.getElementById('branchName').value = branch;
            addTerminalOutput(`$ Switched to branch: ${branch}`);
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 's':
                        e.preventDefault();
                        gitPush();
                        break;
                    case 'r':
                        e.preventDefault();
                        pullAndRun();
                        break;
                    case 'f':
                        e.preventDefault();
                        gitFetch();
                        break;
                }
            }
        });

        // Auto-save functionality
        setInterval(() => {
            if (currentFile && fileContents[currentFile]) {
                // Auto-save indication could be added here
                localStorage.setItem('autosave_' + currentFile, fileContents[currentFile]);
            }
        }, 30000); // Auto-save every 30 seconds

        // Initialize with default file
        selectFile('app.py');
    </script>
</body>
</html>