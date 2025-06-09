# 🚀 现代个人博客系统 (Cloudflare Workers + AI)

基于 Cloudflare Workers 的现代个人博客系统，集成可视化写作、智能天气显示、AI 自动配图等功能。

## ✨ 功能特色

- 🌐 **无服务器架构**: 基于 Cloudflare Workers + Pages 部署
- ✍️ **可视化写作**: 集成 TipTap 富文本编辑器
- 🌤️ **智能天气**: 自动定位 + 高德地图天气 API
- 🎨 **AI 配图**: Minimax API 自动生成文章配图
- 📱 **响应式设计**: 支持桌面和移动端
- 🌙 **夜间模式**: 深色/浅色主题切换
- 💬 **评论系统**: 集成 Giscus 评论
- 🔍 **全文搜索**: 基于 fuse.js 的本地搜索

## 🛠 技术栈

### 前端

- **React 18** + **TypeScript**
- **Tailwind CSS** - 原子化 CSS
- **TipTap** - 现代富文本编辑器
- **Framer Motion** - 动画效果
- **Fuse.js** - 全文搜索

### 后端

- **Cloudflare Workers** - 边缘计算 API
- **Cloudflare KV** - 键值存储
- **GitHub API** - 文章同步

### 第三方服务

- **高德地图 API** - 天气数据
- **Minimax API** - AI 图像生成
- **Giscus** - 评论系统

## 📁 项目结构

```text
blog-system/
├── frontend/                 # React 前端项目
│   ├── src/
│   │   ├── components/      # 公共组件
│   │   ├── pages/          # 页面组件
│   │   ├── hooks/          # 自定义 Hooks
│   │   ├── utils/          # 工具函数
│   │   └── styles/         # 样式文件
│   ├── public/             # 静态资源
│   └── package.json
├── workers/                 # Cloudflare Workers
│   ├── weather-api/        # 天气 API Worker
│   ├── blog-api/          # 博客 API Worker
│   └── ai-image/          # AI 配图 Worker
├── docs/                   # 文档
│   ├── deployment.md      # 部署指南
│   └── api.md            # API 文档
└── README.md
```

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd blog-system
```

### 2. 安装依赖

```bash
# 前端依赖
cd frontend
npm install

# Workers 依赖
cd ../workers
npm install
```

### 3. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量
# - AMAP_API_KEY: 高德地图API密钥
# - MINIMAX_API_KEY: Minimax API密钥
# - GITHUB_TOKEN: GitHub API令牌
```

### 4. 本地开发

```bash
# 启动前端开发服务器
cd frontend
npm run dev

# 启动 Workers 本地调试
cd workers
npm run dev
```

### 5. 一键部署到 Cloudflare

**Windows 用户:**
```powershell
.\deploy.ps1
```

**Mac/Linux 用户:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**或者手动部署:**
```bash
# 部署前端到 Pages
npm run deploy:frontend

# 部署 Workers
npm run deploy:workers
```

## 📖 功能详解

### 可视化写作系统

- 支持 Markdown 和富文本模式
- 实时预览功能
- 自动保存草稿
- 文章元数据编辑（标题、标签、分类等）

### 智能天气显示

- 自动获取用户地理位置
- 调用高德地图 API 获取天气信息
- 在博客页面显示当前天气状况

### AI 自动配图

- 基于文章标题和内容生成配图
- 支持多种图片风格选择
- 自动保存到 CDN

### 博客核心功能

- 文章列表展示与分页
- 文章详情页面
- 分类和标签管理
- 评论互动系统
- 搜索功能

## 🔧 配置说明

### Cloudflare 配置

详见 [deployment.md](docs/deployment.md)

### API 密钥获取

1. **高德地图**: [https://lbs.amap.com/](https://lbs.amap.com/)
2. **Minimax**: [https://www.minimax.chat/](https://www.minimax.chat/)
3. **GitHub**: [https://github.com/settings/tokens](https://github.com/settings/tokens)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## Created with ❤️ by AI Assistant