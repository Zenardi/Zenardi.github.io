# Eduardo Zenardi's Portfolio Website

A personal portfolio website built with Jekyll and the [portfolYOU](https://github.com/yousinix/portfolYOU) theme, showcasing professional experience, projects, blog posts, and certifications.

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Ruby** (version 2.7.0 or higher)
  - Check version: `ruby --version`
  - Install: [Ruby Installation Guide](https://www.ruby-lang.org/en/documentation/installation/)
  
- **RubyGems** (usually comes with Ruby)
  - Check version: `gem --version`
  
- **Bundler**
  - Install: `gem install bundler`

- **Git**
  - Check version: `git --version`

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Zenardi/Zenardi.github.io.git
   cd Zenardi.github.io
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

   This will install Jekyll, GitHub Pages gem, and all required dependencies.

## 🛠️ Local Development

### Running the Development Server

To run the site locally with live reload:

```bash
bundle exec jekyll serve
```

Or with live reload and drafts:

```bash
bundle exec jekyll serve --livereload --drafts
```

The site will be available at: `http://localhost:4000`

The server will automatically rebuild the site when you make changes to files.

### Building the Site

To build the site for production:

```bash
bundle exec jekyll build
```

The generated static site will be in the `_site/` directory.

### Cleaning Build Files

To remove the generated site and cache:

```bash
bundle exec jekyll clean
```

## 📁 Project Structure

```
.
├── _config.yml           # Site configuration
├── Gemfile               # Ruby dependencies
├── pages/                # Main pages (About, Blog, Projects, etc.)
├── _posts/               # Blog posts (YYYY-MM-DD-title.md)
├── _projects/            # Project descriptions
├── _data/                # Data files (YAML)
│   ├── skills.yml
│   ├── programming-skills.yml
│   ├── other-skills.yml
│   ├── professional-experience.yml
│   ├── timeline.yml
│   ├── certifications.yml
│   └── social-media.yml
├── assets/               # Static assets
│   ├── img/              # Images
│   └── resume/           # Resume files
├── images/               # Additional images
└── _site/                # Generated site (do not edit)
```

## ✏️ Customization

### Updating Content

#### Personal Information
Edit `_config.yml` to update:
- Name, title, and description
- Social media links
- Site settings

#### Skills & Experience
Update YAML files in the `_data/` directory:
- `skills.yml` - Technical skills
- `professional-experience.yml` - Work history
- `timeline.yml` - Education timeline
- `certifications.yml` - Certifications

#### Blog Posts
Create new blog posts in `_posts/` directory:
- Format: `YYYY-MM-DD-post-title.md`
- Include front matter with title, tags, etc.

#### Projects
Add project descriptions in `_projects/` directory.

#### Resume
Place your resume PDF in `assets/resume/` directory.

### Theme Customization

This site uses the [portfolYOU](https://github.com/yousinix/portfolYOU) theme. For advanced customization:
- Override theme files by creating matching files in your repository
- Customize styles in `assets/css/`
- Modify layouts by creating files in `_layouts/`

## 🚢 Deployment

This site is configured for GitHub Pages deployment:

1. **Automatic Deployment**
   - Push changes to the `main` branch
   - GitHub Pages will automatically build and deploy

2. **Manual Deployment**
   - Build locally: `bundle exec jekyll build`
   - Upload `_site/` contents to your hosting provider

## 🔧 Configuration

### Environment Variables

For GitHub metadata features, set:
```bash
export JEKYLL_GITHUB_TOKEN=your_github_token
```

### Common Issues

**Issue: Bundle install fails**
```bash
# Update RubyGems
gem update --system

# Install bundler
gem install bundler

# Try again
bundle install
```

**Issue: Port 4000 already in use**
```bash
# Use a different port
bundle exec jekyll serve --port 4001
```

**Issue: Permission errors on Linux/Mac**
```bash
# Install gems to user directory
bundle install --path vendor/bundle
```

## 📝 Adding New Content

### Creating a Blog Post

1. Create a new file in `_posts/`:
   ```bash
   touch _posts/2026-02-17-my-new-post.md
   ```

2. Add front matter:
   ```yaml
   ---
   title: My New Post
   tags: [DevOps, Kubernetes]
   style: fill
   color: primary
   description: Post description
   ---
   ```

3. Write your content in Markdown

### Adding a Project

1. Create a new file in `_projects/`:
   ```bash
   touch "_projects/(7) My New Project.md"
   ```

2. Add front matter with project details

## 🔗 Useful Commands

| Command | Description |
|---------|-------------|
| `bundle exec jekyll serve` | Run development server |
| `bundle exec jekyll build` | Build for production |
| `bundle exec jekyll clean` | Remove generated files |
| `bundle update` | Update dependencies |
| `bundle exec jekyll serve --drafts` | Preview draft posts |
| `bundle exec jekyll serve --livereload` | Auto-reload on changes |

## 📚 Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [portfolYOU Theme](https://github.com/yousinix/portfolYOU)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Markdown Guide](https://www.markdownguide.org/)

## 🤖 Claude Code

This repo is set up for [Claude Code](https://claude.ai/code). `CLAUDE.md` gives Claude
the project conventions (remote theme, build commands, content model), and a few
slash-command skills speed up common content tasks:

| Command | Description |
|---------|-------------|
| `/add-cert` | Add a certification to `_data/certifications.yml` and place its badge image |
| `/new-post` | Scaffold a `_posts/YYYY-MM-DD-title.md` blog post with the right front matter |
| `/new-project` | Scaffold a numbered `_projects/(N) Name.md` project file |
| `/serve` | Run the local Jekyll dev server |

A PostToolUse hook also validates any edited `_data/*.yml` file so a YAML typo can't
silently break the GitHub Pages build.

## 📄 License

This project is open source and available for personal use.

## 📧 Contact

For questions or suggestions, reach out through:
- GitHub: [@Zenardi](https://github.com/Zenardi)
- Website: [Zenardi.github.io](https://zenardi.github.io)
