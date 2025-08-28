#!/bin/bash
# Worktree Manager - 작업 분배 및 관리 도구

set -euo pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
WORKTREES_DIR=".worktrees"

# 도움말
show_help() {
    cat <<EOF
Worktree Manager - Git Worktree 작업 분배 도구

Usage: $0 {init|distribute|status|sync|help}

Commands:
  init       - PLAN.md 템플릿 생성
  distribute - PLAN.md 기반으로 작업 분배
  status     - 모든 worktree 상태 확인
  sync       - worktree 간 환경 파일 동기화
  help       - 이 도움말 표시

Example:
  $0 init                    # 초기 설정
  vim .worktrees/PLAN.md     # 작업 계획 편집
  $0 distribute              # 작업 분배
  cd .worktrees/auth         # worktree로 이동
  claude                     # Claude 실행

EOF
}

# PLAN.md 템플릿 생성
create_plan_template() {
    mkdir -p "$WORKTREES_DIR"
    
    if [[ -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${YELLOW}⚠ PLAN.md already exists${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    cat > "$WORKTREES_DIR/PLAN.md" <<'EOF'
# 작업 계획

## 작업 목록
```bash
# 형식: task-name: 작업 설명
# 예시:
auth: 사용자 인증 시스템 구현 (OAuth2.0, JWT)
payment: 결제 모듈 구현 (Stripe 연동)
search: 검색 기능 구현 (Elasticsearch)
```

## 공통 컨텍스트
- TypeScript 사용
- 테스트 코드 포함
- REST API 규격 준수
- 에러 처리 통일

## 참고사항
- 각 작업은 독립적으로 실행 가능해야 함
- 브랜치명은 feature/task-name 형식으로 자동 생성
- 작업별 지시서는 .worktrees/tasks/ 폴더에 생성됨
EOF
    
    echo -e "${GREEN}✓ Created PLAN.md template at $WORKTREES_DIR/PLAN.md${NC}"
    echo -e "${BLUE}Next step: Edit the file and run '$0 distribute'${NC}"
}

# 환경 파일 복사
copy_env_files() {
    local worktree_path=$1
    local root_path=$2
    
    # 복사할 파일 목록
    local env_files=(
        ".env"
        ".env.local"
        ".env.development"
        ".env.production"
        "package.json"
        "package-lock.json"
        "yarn.lock"
        "pnpm-lock.yaml"
        "tsconfig.json"
        "tsconfig.node.json"
        "vite.config.ts"
        "vite.config.js"
        "next.config.js"
        "next.config.ts"
        ".eslintrc"
        ".eslintrc.json"
        ".prettierrc"
        ".prettierrc.json"
        "prettier.config.js"
        ".nvmrc"
        ".npmrc"
        "pyproject.toml"
        "requirements.txt"
        "Pipfile"
        "Pipfile.lock"
        "Gemfile"
        "Gemfile.lock"
        "docker-compose.yml"
        "docker-compose.yaml"
    )
    
    local copied_count=0
    for file in "${env_files[@]}"; do
        if [[ -f "$root_path/$file" ]]; then
            cp "$root_path/$file" "$worktree_path/" 2>/dev/null || true
            echo "    ✓ Copied $file"
            ((copied_count++))
        fi
    done
    
    # node_modules 심링크 (존재하는 경우)
    if [[ -d "$root_path/node_modules" && ! -e "$worktree_path/node_modules" ]]; then
        local abs_node_modules=$(cd "$root_path" && pwd)/node_modules
        ln -s "$abs_node_modules" "$worktree_path/node_modules"
        echo "    ✓ Linked node_modules"
    fi
    
    # Python venv 심링크
    if [[ -d "$root_path/venv" && ! -e "$worktree_path/venv" ]]; then
        local abs_venv=$(cd "$root_path" && pwd)/venv
        ln -s "$abs_venv" "$worktree_path/venv"
        echo "    ✓ Linked venv"
    fi
    
    if [[ $copied_count -eq 0 ]]; then
        echo "    ℹ No environment files found to copy"
    fi
}

# 작업 분배
distribute_tasks() {
    if [[ ! -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${RED}✗ PLAN.md not found${NC}"
        echo -e "${YELLOW}Creating template...${NC}"
        create_plan_template
        return 1
    fi
    
    # tasks 디렉토리 생성
    mkdir -p "$WORKTREES_DIR/tasks"
    
    echo -e "${BLUE}📋 Parsing PLAN.md...${NC}\n"
    
    local task_count=0
    local in_block=false
    
    # PLAN.md 파싱
    while IFS= read -r line; do
        if [[ "$line" == '```bash' ]]; then
            in_block=true
        elif [[ "$line" == '```' ]]; then
            in_block=false
        elif [[ "$in_block" == true ]] && [[ "$line" =~ ^([a-z][a-z0-9-]*):\ *(.+)$ ]]; then
            local task_name="${BASH_REMATCH[1]}"
            local task_desc="${BASH_REMATCH[2]}"
            
            # 주석 라인 스킵
            if [[ "$line" =~ ^#.*$ ]]; then
                continue
            fi
            
            echo -e "${BLUE}📦 Setting up: $task_name${NC}"
            echo "   Description: $task_desc"
            
            # Worktree 생성
            local worktree_path="$WORKTREES_DIR/$task_name"
            local branch_name="feature/$task_name"
            
            if [[ -d "$worktree_path" ]]; then
                echo -e "    ${YELLOW}⚠ Worktree already exists${NC}"
            else
                # 브랜치가 이미 존재하는지 확인
                if git show-ref --verify --quiet "refs/heads/$branch_name"; then
                    git worktree add "$worktree_path" "$branch_name" 2>/dev/null
                    echo "    ✓ Added worktree (existing branch)"
                else
                    git worktree add "$worktree_path" -b "$branch_name" 2>/dev/null
                    echo "    ✓ Created worktree (new branch)"
                fi
            fi
            
            # 환경 파일 복사
            echo "    📄 Copying environment files..."
            copy_env_files "$worktree_path" "."
            
            # 작업 지시서 생성
            cat > "$WORKTREES_DIR/tasks/$task_name.md" <<EOF
# Task: $task_name

## 📋 작업 내용
$task_desc

## 🚀 시작하기

1. Worktree로 이동:
\`\`\`bash
cd $worktree_path
\`\`\`

2. Claude 실행:
\`\`\`bash
claude
\`\`\`

3. 이 파일의 작업 내용 참조해서 구현 시작

## 📁 파일 위치
- **작업 디렉토리**: \`$worktree_path\`
- **브랜치**: \`$branch_name\`
- **공통 컨텍스트**: \`../$WORKTREES_DIR/CONTEXT.md\`
- **작업 계획**: \`../$WORKTREES_DIR/PLAN.md\`

## ✅ 완료 기준
- [ ] 기능 구현 완료
- [ ] 테스트 코드 작성
- [ ] 문서 업데이트
- [ ] 코드 리뷰 준비

## 📝 Notes
- 환경 파일(.env 등)은 이미 복사됨
- node_modules는 심링크로 연결됨
- 다른 worktree와 독립적으로 작업 가능

---
Generated: $(date '+%Y-%m-%d %H:%M:%S')
EOF
            echo "    ✓ Created task file: tasks/$task_name.md"
            echo ""
            
            ((task_count++))
        fi
    done < "$WORKTREES_DIR/PLAN.md"
    
    if [[ $task_count -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No tasks found in PLAN.md${NC}"
        echo "Please check the format in PLAN.md"
        return 1
    fi
    
    # 완료 메시지
    echo -e "${GREEN}✅ 작업 분배 완료! ($task_count tasks)${NC}\n"
    echo -e "${BLUE}다음 단계:${NC}"
    echo "각 worktree로 이동해서 Claude 실행:"
    echo ""
    
    # 생성된 worktree 목록 표시
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local task_name=$(basename "$dir")
            echo "  cd $dir && claude"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Tip:${NC} 각 터미널/탭에서 별도로 실행하면 병렬 작업 가능"
}

# 상태 확인
show_status() {
    echo -e "${BLUE}═══════════════════════════════${NC}"
    echo -e "${BLUE}     Worktree Status${NC}"
    echo -e "${BLUE}═══════════════════════════════${NC}\n"
    
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Run '$0 init' to get started"
        return
    fi
    
    local worktree_found=false
    
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            worktree_found=true
            local task_name=$(basename "$dir")
            
            # 작업 디렉토리로 이동
            pushd "$dir" > /dev/null
            
            local branch=$(git branch --show-current)
            local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            local commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
            local last_commit=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "No commits yet")
            
            # 상태 아이콘 결정
            local status_icon="🔄"
            if [[ $changes -eq 0 && $commits -gt 0 ]]; then
                status_icon="✅"
            elif [[ $changes -gt 0 ]]; then
                status_icon="📝"
            fi
            
            echo -e "${GREEN}$status_icon $task_name${NC}"
            echo "   Branch: $branch"
            echo "   Changes: $changes file(s)"
            echo "   Commits: $commits"
            echo "   Last: $last_commit"
            
            # Task 파일 확인
            if [[ -f "../tasks/$task_name.md" ]]; then
                echo "   Task: ../tasks/$task_name.md"
            fi
            
            echo ""
            
            popd > /dev/null
        fi
    done
    
    if [[ "$worktree_found" == false ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Run '$0 distribute' after creating PLAN.md"
    fi
    
    # Git worktree list 요약
    echo -e "${BLUE}───────────────────────────────${NC}"
    echo -e "${BLUE}Git Worktree Summary:${NC}"
    git worktree list 2>/dev/null | grep "$WORKTREES_DIR" || echo "No git worktrees found"
}

# 환경 파일 동기화
sync_env_files() {
    echo -e "${BLUE}🔄 Syncing environment files...${NC}\n"
    
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        return
    fi
    
    local sync_count=0
    
    # 동기화할 파일 목록
    local sync_files=(
        ".env"
        ".env.local"
        "package.json"
    )
    
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local task_name=$(basename "$dir")
            echo -e "${BLUE}Checking: $task_name${NC}"
            
            for file in "${sync_files[@]}"; do
                if [[ -f "$file" ]]; then
                    if [[ ! -f "$dir/$file" ]] || [[ "$file" -nt "$dir/$file" ]]; then
                        cp "$file" "$dir/"
                        echo "  ✓ Updated $file"
                        ((sync_count++))
                    fi
                fi
            done
            
            echo ""
        fi
    done
    
    if [[ $sync_count -eq 0 ]]; then
        echo -e "${GREEN}✓ All files are up to date${NC}"
    else
        echo -e "${GREEN}✅ Synced $sync_count file(s)${NC}"
        echo -e "${YELLOW}Note: Run 'npm install' in worktrees if package.json was updated${NC}"
    fi
}

# 메인 함수
main() {
    # Git repository 확인
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}✗ Not a git repository${NC}"
        echo "Please run this script in a git repository"
        exit 1
    fi
    
    case "${1:-help}" in
        init)
            create_plan_template
            ;;
        distribute)
            distribute_tasks
            ;;
        status)
            show_status
            ;;
        sync)
            sync_env_files
            ;;
        help|*)
            show_help
            ;;
    esac
}

# 스크립트 실행
main "$@"