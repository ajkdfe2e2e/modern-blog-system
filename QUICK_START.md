# 🚀 博客系统快速开始指南

只需 3 步，即可拥有自己的现代博客系统！

## 📋 准备工作

1. **注册 Cloudflare 账户** (免费): [https://www.cloudflare.com/](https://www.cloudflare.com/)
2. **获取 API 密钥**:
   - 高德地图 API: [https://lbs.amap.com/](https://lbs.amap.com/)
   - Minimax API: [https://www.minimax.chat/](https://www.minimax.chat/)

## 🎯 一键部署

### Windows 用户

1. 打开 PowerShell (管理员权限)
2. 运行部署脚本:
   ```powershell
   .\deploy.ps1
   ```

### Mac/Linux 用户

1. 打开终端
2. 给脚本执行权限并运行:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 📝 部署过程

脚本会自动完成：

1. ✅ **环境检查** - 检查 Node.js 和 wrangler CLI
2. 🔐 **Cloudflare 登录** - 引导登录您的账户
3. 🔑 **API 密钥设置** - 安全设置第三方服务密钥
4. 🗄️ **数据库创建** - 自动创建 KV 存储空间
5. ⚡ **后端部署** - 部署 3 个 Worker 服务
6. 🌐 **前端部署** - 部署到 Cloudflare Pages
7. 🔧 **配置更新** - 自动配置 API 端点

## 🎉 完成后

部署成功后，您将获得：

- 📱 **博客前端地址** - 您的个人博客网站
- ⚡ **天气 API** - 自动显示当前天气
- 🎨 **AI 配图 API** - 智能生成文章配图  
- 📚 **博客 API** - 文章管理后端

## 🛠️ 使用功能

### 1. 发布文章
- 访问博客网站
- 点击"写文章"
- 使用富文本编辑器创作
- 点击"AI配图"按钮自动生成配图

### 2. 管理文章
- 编辑已发布的文章
- 设置文章分类和标签
- 控制文章显示状态

### 3. 查看数据
- 在 Cloudflare Dashboard 中查看访问统计
- 监控 API 调用次数
- 管理 KV 存储内容

## 🆘 遇到问题？

### 常见问题

**Q: 部署失败了怎么办？**
A: 检查网络连接，确保已正确登录 Cloudflare，重新运行部署脚本。

**Q: API 密钥在哪里找？**
A: 查看 [API 密钥获取指南](docs/api-keys.md)

**Q: 天气功能不显示？**
A: 检查浏览器是否允许地理位置权限，确认高德地图 API 密钥正确。

**Q: AI 配图生成失败？**
A: 确认 Minimax API 密钥正确，检查账户余额。

### 获取帮助

- 📖 查看完整文档: [deployment.md](docs/deployment.md)
- 🐛 报告问题: [GitHub Issues](https://github.com/your-repo/issues)
- 💬 社区讨论: [Discussions](https://github.com/your-repo/discussions)

---

**享受您的现代博客之旅！** 🎉