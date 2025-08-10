# Backend Setup Guide

## 📋 Requirements File

Create `backend/requirements.txt`:

```txt
# Core Flask framework
Flask==2.3.3
Flask-CORS==4.0.0

# Git operations
GitPython==3.1.37

# Looker SDK
looker-sdk==22.20.0

# Environment and configuration
python-dotenv==1.0.0

# Additional utilities
requests==2.31.0
PyYAML==6.0.1

# Development tools (optional)
pytest==7.4.3
black==23.9.1
flake8==6.1.0
```

## 🚀 Setup Instructions

### 1. **Create Project Structure**

```bash
your-project/
├── backend/
│   ├── app.py                 # Main Flask application
│   ├── requirements.txt       # Python dependencies
│   ├── .env                   # Environment variables
│   └── workspace/            # Git repositories workspace
├── index.html                # Frontend HTML file
└── README.md                 # Project documentation
```

### 2. **Environment Setup**

Create `backend/.env` file:

```env
# GitHub Configuration
GITHUB_TOKEN=ghp_your_github_token_here

# Looker Configuration
LOOKER_BASE_URL=https://your-instance.looker.com
LOOKER_CLIENT_ID=your_client_id
LOOKER_CLIENT_SECRET=your_client_secret

# Application Configuration
WORKSPACE_DIR=./workspace
FLASK_ENV=development
FLASK_DEBUG=True
```

### 3. **Installation Commands**

```bash
# Navigate to project directory
cd your-project

# Create Python virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Navigate to backend
cd backend

# Install dependencies
pip install -r requirements.txt

# Run the backend server
python app.py
```

### 4. **Frontend Integration**

Update your frontend JavaScript to use the backend API instead of simulations. Here are the key changes needed:

```javascript
// Replace simulation functions with real API calls

// Git Operations
async function gitFetch() {
    try {
        updateStatusIndicator('Fetching from GitHub...', 'loading');
        
        const response = await fetch('http://localhost:5000/api/git/fetch', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        
        const result = await response.json();
        
        if (result.success) {
            addTerminalOutput('✓ ' + result.message);
            updateStatusIndicator('Fetch completed successfully', 'success');
        } else {
            addTerminalOutput('✗ ' + result.error);
            updateStatusIndicator('Fetch failed', 'error');
        }
    } catch (error) {
        addTerminalOutput('✗ Network error: ' + error.message);
        updateStatusIndicator('Fetch failed', 'error');
    }
}

async function gitPush() {
    const commitMessage = document.getElementById('commitMessage').value;
    if (!commitMessage.trim()) {
        alert('Please enter a commit message');
        return;
    }

    try {
        updateStatusIndicator('Pushing to GitHub...', 'loading');
        
        const response = await fetch('http://localhost:5000/api/git/push', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                commit_message: commitMessage,
                files: null // Will add all files
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            addTerminalOutput('✓ ' + result.message);
            updateStatusIndicator('Push completed successfully', 'success');
            document.getElementById('commitMessage').value = '';
        } else {
            addTerminalOutput('✗ ' + result.error);
            updateStatusIndicator('Push failed', 'error');
        }
    } catch (error) {
        addTerminalOutput('✗ Network error: ' + error.message);
        updateStatusIndicator('Push failed', 'error');
    }
}

// Looker Operations
async function testLookerConnection() {
    const host = document.getElementById('lookerHost').value;
    const clientId = document.getElementById('lookerClientId').value;
    const clientSecret = document.getElementById('lookerClientSecret').value;
    
    if (!host || !clientId || !clientSecret) {
        alert('Please enter all Looker credentials');
        return;
    }

    try {
        updateStatusIndicator('Testing Looker connection...', 'loading');
        
        const response = await fetch('http://localhost:5000/api/looker/connect', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                base_url: host,
                client_id: clientId,
                client_secret: clientSecret
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            addTerminalOutput('✓ ' + result.message);
            updateStatusIndicator('Looker connected successfully', 'success');
        } else {
            addTerminalOutput('✗ ' + result.error);
            updateStatusIndicator('Looker connection failed', 'error');
        }
    } catch (error) {
        addTerminalOutput('✗ Network error: ' + error.message);
        updateStatusIndicator('Looker connection failed', 'error');
    }
}

// Initialize repository on page load
async function initializeRepository() {
    const repoUrl = document.getElementById('repoUrl').value;
    const githubToken = document.getElementById('githubToken').value;
    
    if (!repoUrl) return;
    
    try {
        const response = await fetch('http://localhost:5000/api/git/clone', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                repo_url: repoUrl,
                token: githubToken
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            // Update file tree with actual repository files
            updateFileTreeFromAPI(result.file_tree);
            addTerminalOutput('✓ Repository loaded successfully');
        }
    } catch (error) {
        addTerminalOutput('✗ Failed to load repository: ' + error.message);
    }
}
```

## 🔧 **API Endpoints**

Your backend provides these endpoints:

### **Git Operations**
- `POST /api/git/clone` - Clone repository
- `POST /api/git/fetch` - Fetch changes
- `POST /api/git/push` - Commit and push
- `POST /api/git/pull` - Pull changes

### **File Operations**
- `GET /api/files/tree` - Get file tree
- `POST /api/files/read` - Read file content
- `POST /api/files/write` - Write file content
- `POST /api/files/upload` - Upload file

### **Looker Operations**
- `POST /api/looker/connect` - Connect to Looker
- `GET /api/looker/dashboards` - Get dashboards
- `POST /api/looker/query` - Run query

### **Execution**
- `POST /api/execute/python` - Execute Python scripts

## 🔒 **Security Setup**

### **GitHub Token**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with these scopes:
   - `repo` (Full repository access)
   - `workflow` (Update GitHub Action workflows)
3. Copy token to `.env` file

### **Looker API Credentials**
1. In Looker Admin → Users → API3 Keys
2. Create new API3 key pair
3. Copy Client ID and Secret to `.env` file

## 🚦 **Testing the Setup**

1. **Start Backend**: `python backend/app.py`
2. **Open Frontend**: Navigate to `http://localhost:5000`
3. **Test Features**:
   - Enter GitHub repository URL
   - Test Git operations
   - Configure Looker credentials
   - Upload files
   - Execute Python scripts

## 🔄 **Development Workflow**

```bash
# Terminal 1: Run backend
cd backend
python app.py

# Terminal 2: Frontend development (if needed)
# Serve frontend files or use live reload tools

# Terminal 3: Testing
curl -X GET http://localhost:5000/api/health
```

## 📝 **Production Deployment**

For production, consider:

1. **Use Production WSGI Server**: Gunicorn, uWSGI
2. **Environment Variables**: Use proper secrets management
3. **Reverse Proxy**: Nginx for serving static files
4. **HTTPS**: SSL certificates for secure communication
5. **Authentication**: Add user authentication system
6. **Rate Limiting**: Protect API endpoints
7. **Logging**: Comprehensive logging system

```bash
# Production example with Gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

This backend setup gives you a fully functional interface with real GitHub and Looker SDK integration!