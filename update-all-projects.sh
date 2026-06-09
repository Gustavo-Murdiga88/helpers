#!/bin/bash

# Script para atualizar todos os projetos Git na pasta fluxo-fxaas-portal-beecambio
# Autor: Diego
# Data: $(date)

# set -e  # Comentado para permitir que o script continue mesmo com erros menores

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log com timestamp
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para log de sucesso
log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓${NC} $1"
}

# Função para log de erro
log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗${NC} $1"
}

# Função para log de aviso
log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠${NC} $1"
}

# Diretório base
BASE_DIR="/Users/gustavomurdiga/projects"

# Lista de projetos e suas respectivas branches (formato "projeto:branch")
PROJECTS=(
    "biome:main"
    "gerenciadordeversao:main"
    "gm-eslint-config:main"
    "grpc:main"
    "ig-wedding:main"
    "mono-repo:main"
    "plataforma_back:main"
    "novo_jmenergy_front:prod"
    "novo_jmenergy_back:main"
    "portfolio:main"
    "sandbox:main"
)

log "🚀 Iniciando atualização de todos os projetos..."
log "📁 Diretório base: $BASE_DIR"
echo

# Contadores para estatísticas
total_projects=${#PROJECTS[@]}
successful_updates=0
failed_updates=0

# Loop através de todos os projetos
for entry in "${PROJECTS[@]}"; do
    project="${entry%%:*}"
    branch="${entry##*:}"
    project_path="$BASE_DIR/$project"
    
    log "📂 Processando projeto: $project (branch: $branch)"
    
    # Verifica se o diretório do projeto existe
    if [ ! -d "$project_path" ]; then
        log_error "Diretório não encontrado: $project_path"
        ((failed_updates++))
        continue
    fi
    
    # Entra no diretório do projeto
    cd "$project_path" || {
        log_error "Não foi possível entrar no diretório: $project_path"
        ((failed_updates++))
        continue
    }
    
    # Verifica se é um repositório Git
    if [ ! -d ".git" ]; then
        log_warning "Não é um repositório Git: $project"
        ((failed_updates++))
        continue
    fi
    
    # Verifica o status atual do Git
    log "🔍 Verificando status do repositório..."
    
    # Verifica se há mudanças não commitadas
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_warning "Há mudanças não commitadas em $project. Pulando atualização."
        ((failed_updates++))
        continue
    fi
    
    # Faz checkout para a branch correta
    log "🔄 Fazendo checkout para branch: $branch"
    if git checkout "$branch" 2>/dev/null; then
        log_success "Checkout para $branch realizado com sucesso"
    else
        log_error "Falha ao fazer checkout para $branch"
        ((failed_updates++))
        continue
    fi
    
    # Faz o pull
    log "⬇️ Executando git pull..."
    if git pull origin "$branch" 2>/dev/null; then
        log_success "Pull realizado com sucesso para $project"
        ((successful_updates++))
    else
        log_error "Falha ao executar git pull para $project"
        ((failed_updates++))
    fi
    
    echo "----------------------------------------"
done

# Volta para o diretório original
cd "$BASE_DIR"

# Estatísticas finais
echo
log "📊 Resumo da atualização:"
log_success "Projetos atualizados com sucesso: $successful_updates"
if [ $failed_updates -gt 0 ]; then
    log_error "Projetos com falha: $failed_updates"
fi
log "Total de projetos processados: $total_projects"

if [ $failed_updates -eq 0 ]; then
    log_success "🎉 Todos os projetos foram atualizados com sucesso!"
else
    log_warning "⚠️ Alguns projetos falharam na atualização. Verifique os logs acima."
fi

echo
log "✅ Script finalizado!"
