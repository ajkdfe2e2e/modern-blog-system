# 博客系统一键部署脚本 (Windows PowerShell)
Write-Host "🚀 开始部署现代个人博客系统..." -ForegroundColor Green

# 检查必要工具
function Check-Requirements {
    Write-Host "📋 检查部署环境..." -ForegroundColor Yellow
    
    # 检查 Node.js
    try {
        $nodeVersion = node --version
        Write-Host "✅ Node.js 已安装: $nodeVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ 请先安装 Node.js" -ForegroundColor Red
        exit 1
    }
    
    # 检查 wrangler
    try {
        $wranglerVersion = wrangler --version
        Write-Host "✅ wrangler CLI 已安装: $wranglerVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ 未找到 wrangler CLI，正在安装..." -ForegroundColor Yellow
        npm install -g wrangler
    }
}

# 登录 Cloudflare
function Login-Cloudflare {
    Write-Host "🔐 检查 Cloudflare 登录状态..." -ForegroundColor Yellow
    
    try {
        $whoami = wrangler whoami 2>$null
        Write-Host "✅ 已登录 Cloudflare: $whoami" -ForegroundColor Green
    }
    catch {
        Write-Host "请先登录 Cloudflare:" -ForegroundColor Yellow
        wrangler login
    }
}

# 设置 API 密钥
function Setup-Secrets {
    Write-Host "🔑 设置 API 密钥..." -ForegroundColor Yellow
    
    Write-Host "请确保已设置以下 API 密钥：" -ForegroundColor Cyan
    Write-Host "- 高德地图 API 密钥" -ForegroundColor Cyan
    Write-Host "- Minimax API 密钥" -ForegroundColor Cyan
    
    $setupKeys = Read-Host "是否需要设置 API 密钥？(y/n)"
    
    if ($setupKeys -eq "y" -or $setupKeys -eq "Y") {
        Write-Host "设置高德地图 API 密钥：" -ForegroundColor Yellow
        wrangler secret put AMAP_API_KEY --name blog-weather-api
        
        Write-Host "设置 Minimax API 密钥：" -ForegroundColor Yellow
        wrangler secret put MINIMAX_API_KEY --name blog-ai-image
    }
}

# 创建 KV 存储
function Setup-KV {
    Write-Host "🗄️ 创建 KV 存储..." -ForegroundColor Yellow
    
    # 创建生产环境 KV
    Write-Host "创建生产环境 KV..." -ForegroundColor Cyan
    $kvResult = wrangler kv:namespace create "POSTS" --json | ConvertFrom-Json
    $kvId = $kvResult.id
    
    # 创建预览环境 KV
    Write-Host "创建预览环境 KV..." -ForegroundColor Cyan
    $kvPreviewResult = wrangler kv:namespace create "POSTS" --preview --json | ConvertFrom-Json
    $kvPreviewId = $kvPreviewResult.id
    
    # 更新 wrangler.toml
    if ($kvId -and $kvPreviewId) {
        $tomlPath = "workers/blog-api/wrangler.toml"
        $content = Get-Content $tomlPath
        $content = $content -replace "your_kv_namespace_id", $kvId
        $content = $content -replace "your_preview_kv_namespace_id", $kvPreviewId
        Set-Content $tomlPath $content
        Write-Host "✅ KV 存储配置完成" -ForegroundColor Green
    }
    
    return @{
        kvId = $kvId
        kvPreviewId = $kvPreviewId
    }
}

# 部署 Workers
function Deploy-Workers {
    Write-Host "⚡ 部署 Workers..." -ForegroundColor Yellow
    
    $urls = @{}
    
    # 部署天气 API
    Write-Host "部署天气 API Worker..." -ForegroundColor Cyan
    Set-Location "workers/weather-api"
    npm install
    wrangler deploy
    $urls.weather = (wrangler info | Select-String "URL:" | ForEach-Object { $_.ToString().Split(" ")[1] })
    Set-Location "../.."
    
    # 部署 AI 配图
    Write-Host "部署 AI 配图 Worker..." -ForegroundColor Cyan
    Set-Location "workers/ai-image"
    npm install
    wrangler deploy
    $urls.aiImage = (wrangler info | Select-String "URL:" | ForEach-Object { $_.ToString().Split(" ")[1] })
    Set-Location "../.."
    
    # 部署博客 API
    Write-Host "部署博客 API Worker..." -ForegroundColor Cyan
    Set-Location "workers/blog-api"
    npm install
    wrangler deploy
    $urls.blog = (wrangler info | Select-String "URL:" | ForEach-Object { $_.ToString().Split(" ")[1] })
    Set-Location "../.."
    
    Write-Host "✅ 所有 Workers 部署完成" -ForegroundColor Green
    Write-Host "📝 记录 API 端点：" -ForegroundColor Cyan
    Write-Host "   天气 API: $($urls.weather)" -ForegroundColor White
    Write-Host "   AI 配图: $($urls.aiImage)" -ForegroundColor White
    Write-Host "   博客 API: $($urls.blog)" -ForegroundColor White
    
    return $urls
}

# 更新前端配置
function Update-FrontendConfig {
    param($urls)
    
    Write-Host "🔧 更新前端 API 配置..." -ForegroundColor Yellow
    
    # 更新主配置文件
    $configPath = "frontend/src/config/api.ts"
    $content = Get-Content $configPath
    
    $content = $content -replace "weather: 'https://blog-weather-api\.your-account\.workers\.dev'", "weather: '$($urls.weather)'"
    $content = $content -replace "aiImage: 'https://blog-ai-image\.your-account\.workers\.dev'", "aiImage: '$($urls.aiImage)'"
    $content = $content -replace "blog: 'https://blog-api\.your-account\.workers\.dev'", "blog: '$($urls.blog)'"
    
    Set-Content $configPath $content
    
    Write-Host "✅ 前端配置更新完成" -ForegroundColor Green
}

# 部署前端
function Deploy-Frontend {
    Write-Host "🌐 部署前端..." -ForegroundColor Yellow
    
    Set-Location "frontend"
    npm install
    npm run build
    
    $projectName = Read-Host "请输入您的博客项目名称"
    if ([string]::IsNullOrWhiteSpace($projectName)) {
        $projectName = "my-blog"
    }
    
    wrangler pages deploy dist --project-name=$projectName
    
    Write-Host "✅ 前端部署完成" -ForegroundColor Green
    Set-Location ".."
}

# 主部署流程
function Main {
    try {
        Check-Requirements
        Login-Cloudflare
        Setup-Secrets
        $kvInfo = Setup-KV
        $urls = Deploy-Workers
        Update-FrontendConfig -urls $urls
        Deploy-Frontend
        
        Write-Host ""
        Write-Host "🎉 部署完成！" -ForegroundColor Green
        Write-Host "您的博客系统已成功部署到 Cloudflare 平台" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 部署信息：" -ForegroundColor Cyan
        Write-Host "   天气 API: $($urls.weather)" -ForegroundColor White
        Write-Host "   AI 配图: $($urls.aiImage)" -ForegroundColor White
        Write-Host "   博客 API: $($urls.blog)" -ForegroundColor White
        Write-Host "   前端地址: 请查看 wrangler pages 输出" -ForegroundColor White
        Write-Host ""
        Write-Host "🔧 后续步骤：" -ForegroundColor Cyan
        Write-Host "1. 访问前端地址查看您的博客" -ForegroundColor White
        Write-Host "2. 在写作页面测试 AI 配图功能" -ForegroundColor White
        Write-Host "3. 检查天气组件是否正常显示" -ForegroundColor White
    }
    catch {
        Write-Host "❌ 部署过程中出现错误: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 执行主流程
Main