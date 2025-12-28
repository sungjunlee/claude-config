---
name: ai
description: |
  Multi-model AI integration for specialized tasks.
  Use when: large file analysis, algorithm optimization, critical decisions.
  Triggers: "gemini", "codex", "multiple AI", "consensus"
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
---

# AI Skill

멀티모델 AI 통합 스킬입니다. 특정 작업에 최적화된 외부 AI 모델을 활용합니다.

## Overview

공식 플러그인에 없는 기능을 제공합니다:
- **Gemini**: 대용량 파일 분석 (무료, 2M 토큰 컨텍스트)
- **Codex**: 알고리즘 최적화, 디버깅 (ChatGPT Plus/Pro)
- **Consensus**: 중요 결정 시 여러 AI 관점
- **Pipeline**: 복잡한 프로젝트 멀티스테이지 분석

## Prerequisites

```bash
# Gemini (Free with Google account)
npm install -g @google/gemini-cli
gemini login

# OpenAI Codex (ChatGPT Plus/Pro subscribers)
npm install -g @openai/codex@latest
codex auth login
```

## Commands

| Command | Purpose | Cost |
|---------|---------|------|
| `/ai:gemini` | Large file analysis | Free |
| `/ai:codex` | Algorithm optimization | Paid |
| `/ai:consensus` | Multi-AI opinions | Mixed |
| `/ai:pipeline` | Multi-stage analysis | Mixed |

## Usage Examples

```bash
# Large file analysis (Free!)
/ai:gemini "analyze entire auth system architecture"

# Algorithm optimization (ChatGPT Plus/Pro)
/ai:codex "optimize this sorting algorithm"

# Critical decisions (multiple perspectives)
/ai:consensus "PostgreSQL vs MongoDB for this use case?"

# Complex projects (multi-stage pipeline)
/ai:pipeline auth.py "security audit"
```

## When to Use

**Use Gemini for:**
- Files > 1000 lines
- Architecture discussions
- Brainstorming sessions

**Use Codex for:**
- Algorithm complexity analysis
- Performance-critical code
- Security-sensitive debugging

**Use Consensus/Pipeline for:**
- Critical architecture decisions
- Complex project analysis
