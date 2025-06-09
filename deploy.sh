#!/bin/bash

# 博客系统一键部署脚本
echo "🚀 开始部署现代个人博客系统..."

# 检查必要工具
check_requirements() {
    echo "📋 检查部署环境..."
    
    if ! command -v wrangler &> /dev/null; then
        echo "❌ 未找到 wrangler CLI，正在安装..."
        npm install -g wrangler
    else
        echo "✅ wrangler CLI 已安装"
    fi
    
    if ! command -v node &> /dev/null; then
        echo "❌ 请先安装 Node.js"
        exit 1
    else
        echo "✅ Node.js 已安装"
    fi
}

# 登录 Cloudflare（如果需要）
login_cloudflare() {
    echo "🔐 检查 Cloudflare 登录状态..."
    if ! wrangler whoami &> /dev/null; then
        echo "请先登录 Cloudflare:"
        wrangler login
    else
        echo "✅ 已登录 Cloudflare"
    fi
}

# 设置 API 密钥
setup_secrets() {
    echo "🔑 设置 API 密钥..."
    
    # 检查是否已设置密钥
    echo "请确保已设置以下 API 密钥："
    echo "- 高德地图 API 密钥"
    echo "- Minimax API 密钥"
    
    read -p "是否需要设置 API 密钥？(y/n): " setup_keys
    
    if [[ $setup_keys == "y" || $setup_keys == "Y" ]]; then
        echo "设置高德地图 API 密钥："
        wrangler secret put AMAP_API_KEY --name blog-weather-api
        
        echo "设置 Minimax API 密钥："
        wrangler secret put MINIMAX_API_KEY --name blog-ai-image
    fi
}

# 创建 KV 存储
setup_kv() {
    echo "🗄️ 创建 KV 存储..."
    
    # 创建 KV 命名空间
    echo "创建生产环境 KV："
    kv_id=$(wrangler kv:namespace create "POSTS" --json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    
    echo "创建预览环境 KV："
    kv_preview_id=$(wrangler kv:namespace create "POSTS" --preview --json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    
    # 更新 wrangler.toml
    if [[ -n "$kv_id" && -n "$kv_preview_id" ]]; then
        sed -i "s/your_kv_namespace_id/$kv_id/g" workers/blog-api/wrangler.toml
        sed -i "s/your_preview_kv_namespace_id/$kv_preview_id/g" workers/blog-api/wrangler.toml
        echo "✅ KV 存储配置完成"
    fi
}

# 部署 Workers
deploy_workers() {
    echo "⚡ 部署 Workers..."
    
    # 部署天气 API
    echo "部署天气 API Worker..."
    cd workers/weather-api
    npm install
    wrangler deploy
    weather_url=$(wrangler info | grep "URL:" | awk '{print $2}')
    cd ../..
    
    # 部署 AI 配图
    echo "部署 AI 配图 Worker..."
    cd workers/ai-image
    npm install
    wrangler deploy
    ai_url=$(wrangler info | grep "URL:" | awk '{print $2}')
    cd ../..
    
    # 部署博客 API
    echo "部署博客 API Worker..."
    cd workers/blog-api
    npm install
    wrangler deploy
    blog_url=$(wrangler info | grep "URL:" | awk '{print $2}')
    cd ../..
    
    echo "✅ 所有 Workers 部署完成"
    echo "📝 记录 API 端点："
    echo "   天气 API: $weather_url"
    echo "   AI 配图: $ai_url"
    echo "   博客 API: $blog_url"
}

# 更新前端配置
update_frontend_config() {
    echo "🔧 更新前端 API 配置..."
    
    # 创建临时配置文件
    cat > frontend/src/config/api.production.ts << EOF
// 生产环境 API 配置（自动生成）
export const PROD_CONFIG = {
  weather: '$weather_url',
  aiImage: '$ai_url',
  blog: '$blog_url'
}
EOF
    
    # 更新主配置文件
    sed -i "s|weather: 'https://blog-weather-api.your-account.workers.dev'|weather: '$weather_url'|g" frontend/src/config/api.ts
    sed -i "s|aiImage: 'https://blog-ai-image.your-account.workers.dev'|aiImage: '$ai_url'|g" frontend/src/config/api.ts
    sed -i "s|blog: 'https://blog-api.your-account.workers.dev'|blog: '$blog_url'|g" frontend/src/config/api.ts
    
    echo "✅ 前端配置更新完成"
}

# 部署前端
deploy_frontend() {
    echo "🌐 部署前端..."
    
    cd frontend
    npm install
    npm run build
    
    read -p "请输入您的博客项目名称: " project_name
    if [[ -z "$project_name" ]]; then
        project_name="my-blog"
    fi
    
    wrangler pages deploy dist --project-name=$project_name
    
    echo "✅ 前端部署完成"
    cd ..
}

# 主部署流程
main() {
    check_requirements
    login_cloudflare
    setup_secrets
    setup_kv
    deploy_workers
    update_frontend_config
    deploy_frontend
    
    echo ""
    echo "🎉 部署完成！"
    echo "您的博客系统已成功部署到 Cloudflare 平台"
    echo ""
    echo "📋 部署信息："
    echo "   天气 API: $weather_url"
    echo "   AI 配图: $ai_url" 
    echo "   博客 API: $blog_url"
    echo "   前端地址: 请查看 wrangler pages 输出"
    echo ""
    echo "🔧 后续步骤："
    echo "1. 访问前端地址查看您的博客"
    echo "2. 在写作页面测试 AI 配图功能"
    echo "3. 检查天气组件是否正常显示"
}

# 执行主流程
main