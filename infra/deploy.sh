#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again."
        exit 1
    fi
    
    log_info "All prerequisites met!"
}

# Create .env file from template
setup_env() {
    if [ ! -f ".env" ]; then
        log_info "Creating .env file from template..."
        cp .env.example .env
        log_warn "Please update .env file with your configuration"
    else
        log_info ".env file already exists"
    fi
}

# Start services
start_services() {
    log_info "Starting services..."
    
    docker-compose up -d
    
    log_info "Waiting for services to be ready..."
    sleep 10
    
    log_info "Services started!"
    docker-compose ps
}

# Stop services
stop_services() {
    log_info "Stopping services..."
    docker-compose down
    log_info "Services stopped!"
}

# View logs
view_logs() {
    local service=$1
    if [ -z "$service" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f $service
    fi
}

# Build services
build_services() {
    log_info "Building services..."
    docker-compose build
    log_info "Services built!"
}

# Health check
health_check() {
    log_info "Running health checks..."
    
    local checks_passed=0
    local checks_total=0
    
    # Check each service
    for service in gateway agent-service vision-service voice-service analytics-service notification-service postgres redis chroma; do
        checks_total=$((checks_total + 1))
        if docker-compose exec -T $service curl -s http://localhost:8000/health > /dev/null 2>&1 || \
           docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1 || \
           docker-compose exec -T redis redis-cli ping > /dev/null 2>&1 || \
           docker-compose exec -T chroma curl -s http://localhost:8000/api/v1/heartbeat > /dev/null 2>&1; then
            checks_passed=$((checks_passed + 1))
            log_info "✓ $service is healthy"
        else
            log_warn "⚠ $service health check failed"
        fi
    done
    
    log_info "Health checks: $checks_passed/$checks_total passed"
}

# Clean up
cleanup() {
    log_warn "Cleaning up Docker resources..."
    docker-compose down -v
    log_info "Cleanup complete!"
}

# Help message
show_help() {
    cat << EOF
HexIdeate Docker Compose Deployment Script

Usage: $0 [COMMAND]

Commands:
    start           Start all services
    stop            Stop all services
    restart         Restart all services
    logs [SERVICE]  View logs (optionally for specific service)
    build           Build all services
    health          Run health checks
    cleanup         Remove all containers and volumes
    help            Show this help message

Examples:
    $0 start                    # Start all services
    $0 logs gateway             # View gateway logs
    $0 health                   # Check service health

EOF
}

# Main
main() {
    local command=$1
    
    case $command in
        start)
            check_prerequisites
            setup_env
            start_services
            health_check
            ;;
        stop)
            stop_services
            ;;
        restart)
            stop_services
            sleep 2
            start_services
            health_check
            ;;
        logs)
            view_logs $2
            ;;
        build)
            build_services
            ;;
        health)
            health_check
            ;;
        cleanup)
            cleanup
            ;;
        help|"")
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
