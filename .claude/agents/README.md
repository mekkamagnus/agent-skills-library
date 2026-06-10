# Project Development Agents

Specialized agents for coordinated development workflow using Claude Code Task System.

## Overview

Five project-agnostic agents work together through a task-based workflow to implement, test, review, and document features:

```
┌─────────────┐
│    User     │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│   Orchestrator  │ ← 🌳 Green - Project Manager (PRIMARY INTERFACE)
│   (Agent)       │
└────────┬────────┘
         │
         │ Creates tasks in Claude Code Task System
         ▼
┌─────────────────────────────────────────────────┐
│          Claude Code Task System                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────┐  │
│  │ Builder  │ →  Tester  │ → Reviewer │→ Doc  │  │
│  │  💙      │ ←  🧪      │ ←  🔍      │  📚   │  │
│  │          │           │           │      │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────┘  │
└─────────────────────────────────────────────────┘
```

**Key Principle**: Users ONLY interact with the Orchestrator agent. The Orchestrator manages all other agents through the Claude Code Task System (TaskCreate, TaskGet, TaskUpdate, TaskList).

## Agent List

### 🌳 Project Orchestrator (`project-orchestrator.md`)
**Color**: Green #4CAF50
**Role**: Project Manager - PRIMARY INTERFACE agent

**Description**:
- ONLY agent that users communicate with directly
- Creates tasks with proper dependencies
- Routes tasks to specialized agents via metadata
- Monitors progress and handles blockers
- Reports results to users

**Key Features**:
- Task creation and dependency management
- Agent coordination through task system
- Progress tracking and reporting
- Error handling and recovery
- Revision cycle management

### 💙 TypeScript Builder (`typescript-builder.md`)
**Color**: Blue #2196F3
**Role**: Implementation Specialist

**Description**:
- Writes clean TypeScript code following Elm Architecture patterns
- Implements immutable state management
- Ensures proper error handling
- Writes testable code
- Addresses review feedback

**Key Features**:
- Elm Architecture patterns (Model-Update-View-Cmd)
- Immutable state updates
- Pure functional programming
- SOLID principles
- Performance optimization

### 🧪 TypeScript Tester (`typescript-tester.md`)
**Color**: Orange #FF9800
**Role**: Testing Specialist

**Description**:
- Writes comprehensive tests achieving >80% coverage
- Tests edge cases and error conditions
- Validates performance targets
- Creates deterministic tests
- Tests behavior, not implementation

**Key Features**:
- Unit tests for all public methods
- Integration tests
- Edge case coverage
- Performance validation
- Golden snapshot testing

### 🔍 Code Reviewer (`code-reviewer.md`)
**Color**: Purple #9C27B0
**Role**: Quality Assurance Specialist

**Description**:
- Reviews code for architecture compliance
- Checks performance and optimization opportunities
- Identifies security vulnerabilities
- Validates test coverage and quality
- Approves implementation OR requests changes

**Key Features**:
- Architecture compliance verification
- Performance analysis
- Security vulnerability detection
- Code quality assessment
- Actionable feedback

### 📚 Documentation Specialist (`documentation-specialist.md`)
**Color**: Teal #009688
**Role**: Documentation Writer

**Description**:
- Creates API documentation for all public modules
- Writes usage examples and practical guides
- Documents component patterns
- Updates README and project documentation
- Ensures documentation matches implementation

**Key Features**:
- API references with JSDoc/TSDoc
- User guides and tutorials
- Component documentation
- Architecture documentation
- Working code examples

## Workflow

The task-based workflow ensures proper sequencing:

```
1. User provides requirements to Orchestrator
          ↓
2. Orchestrator creates tasks with dependencies:
   - Builder task (no dependencies)
   - Tester task (addBlockedBy: [builder.id])
   - Reviewer task (addBlockedBy: [tester.id])
   - Documentor task (addBlockedBy: [reviewer.id])
          ↓
3. Builder finds and claims task (metadata.agent === "typescript-builder")
          ↓
4. Builder implements feature → marks task complete
          ↓
5. Tester task unblocked (blockedBy.length === 0)
          ↓
6. Tester writes tests → marks task complete
          ↓
7. Reviewer task unblocked
          ↓
8. Reviewer reviews code:
       ┌───┴───┐
       │       │
    Approve  Request Changes
       │       │
       │       └────────────────────────┐
       │                                  │
       ↓                                  ↓
9. Documentor task unblocked        Builder sees feedback
   (writes documentation)              (creates revision task)
       │                                  │
       │                                  └──→ Back to step 3
       ↓
10. All tasks complete → Orchestrator reports to user
```

## Quick Reference

**Agent Names** (for task metadata):
- `project-orchestrator` - Task creation and coordination
- `typescript-builder` - Implementation
- `typescript-tester` - Testing
- `code-reviewer` - Quality assurance
- `documentation-specialist` - Documentation

**Agent Colors**:
- 🌳 Green #4CAF50 - Orchestrator (coordination, success)
- 💙 Blue #2196F3 - Builder (construction, stability)
- 🧪 Orange #FF9800 - Tester (validation, scrutiny)
- 🔍 Purple #9C27B0 - Reviewer (wisdom, evaluation)
- 📚 Teal #009688 - Documentor (clarity, communication)

**Task Creation Pattern**:
```typescript
// Builder task
const build = await TaskCreate({
  subject: "Implement feature",
  metadata: { agent: "typescript-builder" }
})

// Tester task (depends on builder)
const test = await TaskCreate({
  subject: "Test feature",
  addBlockedBy: [build.id],
  metadata: { agent: "typescript-tester" }
})

// Reviewer task (depends on tester)
const review = await TaskCreate({
  subject: "Review feature",
  addBlockedBy: [test.id],
  metadata: { agent: "code-reviewer" }
})

// Documentor task (depends on reviewer)
const doc = await TaskCreate({
  subject: "Document feature",
  addBlockedBy: [review.id],
  metadata: { agent: "documentation-specialist" }
})
```

## Best Practices

1. **For Users**:
   - ONLY communicate with the Orchestrator agent
   - Provide clear, complete requirements
   - Reference relevant documentation
   - Trust the process (allow iteration)

2. **For Orchestrator**:
   - Create comprehensive task descriptions
   - Set proper dependencies
   - Monitor progress regularly
   - Handle feedback gracefully
   - Report clearly to users

3. **For Agents** (Builder, Tester, Reviewer, Documentor):
   - NEVER communicate directly to users
   - Find tasks via TaskList filtering
   - Claim tasks with TaskUpdate
   - Mark tasks complete when done
   - Provide status via task metadata

4. **For Quality**:
   - Never skip review step
   - Address all review feedback
   - Maintain test coverage >80%
   - Document architectural decisions
   - Follow architecture patterns

## Agent Configuration

Each agent file contains:

- **YAML Frontmatter**: `name`, `description`, `color`, `tools`, `model`
- **Role and responsibilities**
- **Task System Integration** workflow
- **Core expertise and patterns**
- **Quality standards**
- **Project context requirements**

To modify agent behavior:
1. Edit the respective `.md` file
2. Update role, responsibilities, or standards
3. Adjust workflow patterns
4. Save changes (Claude Code loads automatically)

## File Naming Convention

All agent files follow kebab-case naming:
- `project-orchestrator.md`
- `typescript-builder.md`
- `typescript-tester.md`
- `code-reviewer.md`
- `documentation-specialist.md`

**Note**: Agent names are **project-agnostic** and designed to be reusable across different TypeScript projects.

## Additional Agents

This directory also contains:

- **UI Coder** (`ui-coder.md`) - Framework-agnostic UI implementation from mockups

## See Also

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Task System Documentation](../docs/claude-code-tasks.md)
