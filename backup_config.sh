#==============================================================================
# 脚本名称: backup_config.sh
# 描述: 备份系统配置文件到指定目录
# 作者: 钟文豪
# 创建日期: 2024-10-06
# 版本: 1.0
# 使用方法: ./backup_config.sh [目标目录]
#==============================================================================

#------------------------------------------------------------------------------
# 全局常量定义
#------------------------------------------------------------------------------
readonly SCRIPT_NAME=$(basename "$0")
readonly DEFAULT_BACKUP_DIR="/backup/configs"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly LOG_FILE="/var/log/backup_config.log"
readonly CONFIG_DIRS=(
    "/etc/nginx"
    "/etc/httpd"
    "/etc/mysql"
    "/etc/ssh"
)

#------------------------------------------------------------------------------
# 函数定义
#------------------------------------------------------------------------------

# 显示脚本用法
usage() {
    cat <<EOF
使用方法: $SCRIPT_NAME [选项] [目标目录]

选项:
  -h, --help     显示帮助信息并退出
  -v, --verbose  显示详细信息

示例:
  $SCRIPT_NAME              # 备份到默认目录
  $SCRIPT_NAME /my/backup   # 备份到指定目录
EOF
}

# 记录日志
log() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
    
    # 如果是错误或启用了详细模式，还要输出到标准输出
    if [[ "$level" == "ERROR" || "$VERBOSE" == true ]]; then
        echo "[$level] $message"
    fi
}

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1 || { 
        log "ERROR" "命令未安装: $1"
        return 1
    }
    return 0
}

# 创建备份目录
create_backup_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log "INFO" "创建备份目录: $dir"
        mkdir -p "$dir" || { 
            log "ERROR" "无法创建备份目录: $dir"
            return 1
        }
    fi
    return 0
}

# 备份配置文件
backup_configs() {
    local backup_dir="$1"
    local success=true
    
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            local dirname=$(basename "$dir")
            local target="$backup_dir/${dirname}_${TIMESTAMP}.tar.gz"
            
            log "INFO" "备份目录: $dir -> $target"
            tar -czf "$target" "$dir" 2>/dev/null || {
                log "ERROR" "备份失败: $dir"
                success=false
                continue
            }
            
            # 检查备份文件大小
            local size=$(du -h "$target" | cut -f1)
            log "INFO" "备份完成: $target ($size)"
        else
            log "WARN" "目录不存在，已跳过: $dir"
        fi
    done
    
    if [[ "$success" == true ]]; then
        log "INFO" "所有配置文件备份成功"
        return 0
    else
        log "WARN" "部分配置文件备份失败"
        return 1
    fi
}

# 清理旧备份 (保留最近7天的备份)
cleanup_old_backups() {
    local backup_dir="$1"
    local days=7
    
    log "INFO" "清理 $days 天前的旧备份"
    find "$backup_dir" -name "*.tar.gz" -type f -mtime +$days -exec rm -f {} \; -exec bash -c 'log "INFO" "删除旧备份: $0"' {} \; 2>/dev/null || {
        log "WARN" "清理旧备份时出错"
        return 1
    }
    
    return 0
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    # 解析命令行参数
    VERBOSE=false
    BACKUP_DIR="$DEFAULT_BACKUP_DIR"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            *)
                BACKUP_DIR="$1"
                shift
                ;;
        esac
    done
    
    # 检查必要的命令
    check_command "tar" || exit 1
    check_command "find" || exit 1
    
    # 创建日志目录
    log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" || {
            echo "错误: 无法创建日志目录: $log_dir"
            exit 1
        }
    fi
    
    # 记录开始备份
    log "INFO" "开始备份配置文件到: $BACKUP_DIR"
    
    # 创建备份目录
    create_backup_dir "$BACKUP_DIR" || exit 1
    
    # 执行备份
    backup_configs "$BACKUP_DIR"
    
    # 清理旧备份
    cleanup_old_backups "$BACKUP_DIR"
    
    log "INFO" "备份过程完成"
    
    if [[ "$VERBOSE" == true ]]; then
        echo "详细日志已保存到: $LOG_FILE"
    fi
    
    return 0
}

# 运行主函数
main "$@"
exit $?