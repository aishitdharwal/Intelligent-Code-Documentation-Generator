# Frontend - AI Code Documentation Generator

Beautiful, simple web interface for the Code Documentation Generator.

## 🚀 Quick Start

### Option 1: Open Directly (Easiest)

```bash
# Just open the HTML file in your browser
open frontend/index.html
# or
google-chrome frontend/index.html
# or
firefox frontend/index.html
```

### Option 2: Serve with Python

```bash
cd frontend
python3 -m http.server 8000
```

Then open: http://localhost:8000

### Option 3: Serve with Node

```bash
cd frontend
npx http-server -p 8000
```

Then open: http://localhost:8000

## ⚙️ Configuration

### First Time Setup

1. Open `index.html` in your browser
2. Click **"Configure"** button next to the API endpoint
3. Paste your API Gateway endpoint URL:
   ```
   https://YOUR-API-ID.execute-api.ap-south-1.amazonaws.com/dev/document
   ```
4. Click OK

The endpoint is saved in browser localStorage, so you only need to do this once!

### Get Your API Endpoint

```bash
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase1 \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text
```

## ✨ Features

### 📝 Code Input
- **Paste or type** Python code directly
- **Load examples** - Quick start with pre-built examples
- **Filename** - Specify your file name
- **Syntax highlighting** - Monaco-style editor feel

### 🤖 Documentation Generation
- **One-click generation** - Press "Generate Documentation" or `Ctrl/Cmd + Enter`
- **Real-time progress** - Loading spinner shows processing status
- **Error handling** - Clear error messages if something goes wrong

### 📊 Statistics
- **Cost tracking** - See exact cost per request in USD
- **Token usage** - Monitor Claude API tokens consumed
- **Processing time** - View generation speed in seconds

### 📄 Output Display
- **Markdown rendering** - Beautiful formatted documentation
- **Copy to clipboard** - One-click copy
- **Download** - Save as `.md` file
- **Syntax highlighting** - Code blocks properly formatted

### 🎨 User Experience
- **Responsive design** - Works on desktop, tablet, mobile
- **Gradient UI** - Beautiful purple gradient theme
- **Smooth animations** - Professional transitions
- **Keyboard shortcuts** - `Ctrl/Cmd + Enter` to generate

## 🎯 Example Workflows

### Simple Function Documentation

1. Click "Simple Function" example
2. Press "Generate Documentation"
3. See formatted docs with function details
4. Copy or download

### Class Documentation

1. Click "Class Example"
2. Generate documentation
3. Review class structure, methods, parameters
4. Save for your team

### Custom Code

1. Paste your own Python code
2. Set filename (e.g., `my_module.py`)
3. Generate
4. Get comprehensive documentation

## 🔧 Technical Details

### Technologies Used
- **Pure HTML/CSS/JavaScript** - No build process needed
- **Marked.js** - Markdown rendering
- **LocalStorage** - Save API endpoint
- **Fetch API** - AJAX requests to backend

### Browser Compatibility
- ✅ Chrome/Edge (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Opera

### File Structure
```
frontend/
├── index.html          # Complete single-page app
└── README.md          # This file
```

Everything is in one HTML file for simplicity!

## 🎓 For Students

### Learning Objectives

This frontend teaches:
1. **REST API integration** - Calling backend endpoints
2. **Async JavaScript** - Fetch API and promises
3. **Error handling** - Graceful failures
4. **UI/UX design** - Professional interface patterns
5. **Markdown rendering** - Content transformation

### Customization Ideas

Students can extend this to add:
- File upload instead of paste
- Batch processing (multiple files)
- History of past generations
- Export to different formats (PDF, HTML)
- Syntax highlighting in input
- Dark mode toggle
- Cost calculator/estimator

## 🚀 Deployment Options

### Option 1: S3 Static Hosting

```bash
# Create S3 bucket
aws s3 mb s3://doc-generator-frontend

# Upload file
aws s3 cp frontend/index.html s3://doc-generator-frontend/index.html --acl public-read

# Enable static website hosting
aws s3 website s3://doc-generator-frontend --index-document index.html

# Access at:
# http://doc-generator-frontend.s3-website.ap-south-1.amazonaws.com
```

### Option 2: GitHub Pages

```bash
# 1. Create a new branch
git checkout -b gh-pages

# 2. Copy frontend to root
cp frontend/index.html index.html

# 3. Commit and push
git add index.html
git commit -m "Add frontend"
git push origin gh-pages

# 4. Enable GitHub Pages in repo settings
# Site will be at: https://USERNAME.github.io/REPO-NAME
```

### Option 3: Netlify/Vercel

1. Drag and drop `frontend` folder to Netlify
2. Done! Instant deployment
3. Get free HTTPS URL

### Option 4: Add to SAM (Advanced)

Update `template.yaml` to serve the frontend from S3 or CloudFront.

## 🔒 CORS Configuration

Make sure your API Gateway has CORS enabled for the frontend domain:

```yaml
# In template.yaml
Cors:
  AllowMethods: "'POST, OPTIONS'"
  AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
  AllowOrigin: "'*'"  # Or specific domain: "'https://yourdomain.com'"
```

If you get CORS errors:
1. Check API Gateway CORS settings
2. Ensure OPTIONS method is enabled
3. Verify headers are allowed

## 💡 Tips

### Keyboard Shortcuts
- `Ctrl/Cmd + Enter` - Generate documentation (while in code textarea)

### Quick Testing
1. Use example buttons for instant testing
2. Check stats to understand costs
3. Download docs for offline use

### Cost Monitoring
- Each generation shows exact cost
- Track spending per request
- Typical cost: $0.002 - $0.05 per file

## 🐛 Troubleshooting

### "Please configure your API endpoint first!"
- Click Configure button
- Paste your API Gateway URL
- Make sure it ends with `/document`

### "Network error"
- Check internet connection
- Verify API endpoint is correct
- Check browser console for details

### CORS Error
- Update API Gateway CORS settings
- Redeploy backend with `sam deploy`

### No documentation generated
- Check if API key is valid
- View CloudWatch logs for backend errors
- Try example code first

## 📱 Mobile Support

The UI is fully responsive and works great on:
- 📱 Phones (vertical layout)
- 📱 Tablets (side-by-side or stacked)
- 💻 Desktops (full grid layout)

## 🎨 Customization

### Change Color Scheme

Edit the gradient colors in the CSS:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
/* Change to your colors */
background: linear-gradient(135deg, #00c6ff 0%, #0072ff 100%);
```

### Add More Examples

Add to the `examples` object:
```javascript
const examples = {
    myExample: {
        filename: 'my_code.py',
        code: `def my_function():\n    pass`
    }
};
```

Then add button:
```html
<button class="example-btn" onclick="loadExample('myExample')">My Example</button>
```

## 🚀 Next Steps

After using the basic frontend:

1. **Add file upload** - Let users upload `.py` files
2. **Batch processing** - Process multiple files at once
3. **History** - Store past generations in localStorage
4. **Export options** - PDF, HTML, Word formats
5. **Live preview** - Split view with code and docs side-by-side

## 📝 License

Part of the Intelligent Code Documentation Generator project.
