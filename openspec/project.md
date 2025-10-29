# Project Context

## Purpose
Memos is a lightweight, self-hosted knowledge management and note-taking platform designed for personal and team use. The project aims to provide a simple, fast, and privacy-focused alternative to commercial note-taking solutions, with features like markdown support, file attachments, memo relationships, and multi-user collaboration.

## Tech Stack

### Backend
- **Go** - Primary backend language
- **gRPC** - Internal service communication
- **gRPC-Gateway** - REST API exposure
- **Echo** - HTTP server framework
- **SQLite/MySQL/PostgreSQL** - Database options (SQLite default)
- **Protocol Buffers** - API contract definitions
- **Cobra** - CLI framework
- **Viper** - Configuration management

### Frontend
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite 7** - Build tool and dev server
- **React Router 7** - Client-side routing
- **MobX** - State management
- **Tailwind CSS 4** - Styling framework
- **Radix UI** - Headless UI components
- **Emotion** - CSS-in-JS styling
- **react-i18next** - Internationalization

### Infrastructure
- **Docker** - Containerization
- **buf** - Protocol Buffer tooling
- **golangci-lint** - Go linting
- **ESLint/Prettier** - Frontend linting/formatting

## Project Conventions

### Code Style

#### Go
- **Formatting**: All code must be `gofmt`-compliant (tabs for indentation)
- **Imports**: Group stdlib, external, and local imports (enforced by `goimports`)
- **Error Handling**: Wrap errors with `%w` when propagating: `errors.Wrap(err, "context")`
- **Naming**: Package names lowercase, no underscores
- **Linting**: Enforced via `.golangci.yaml` (revive, staticcheck, gocritic, etc.)

#### TypeScript/React
- **Components**: PascalCase filenames (e.g., `MemoEditor.tsx`)
- **Hooks**: camelCase filenames (e.g., `useMemoList.ts`)
- **Formatting**: Prettier enforced (see `web/.prettierrc.js`)
- **Import Ordering**: Managed by `@trivago/prettier-plugin-sort-imports`
- **Styling**: Tailwind utility classes preferred over custom CSS

### Architecture Patterns

#### Backend Architecture
- **Repository Pattern**: Data access layer abstracted through `store.Driver` interface
- **Dual Protocol Serving**: HTTP/2 + gRPC on same port using `cmux`
- **Service Layer**: gRPC services in `server/router/api/v1/`
- **Database Abstraction**: Multiple driver implementations (SQLite, MySQL, PostgreSQL)
- **Migration System**: Versioned schema migrations per driver

#### Frontend Architecture
- **Component-Based**: React functional components with hooks
- **State Management**: MobX stores for global state (`web/src/store/`)
- **gRPC-Web Client**: Direct backend communication via `nice-grpc-web`
- **Modular Structure**: Organized by feature/domain

#### API Design
- **Protocol Buffers**: Service contracts defined in `proto/api/v1/`
- **Dual Access**: Native gRPC + REST API via gRPC-Gateway
- **Authentication**: Session-based (cookies) + Token-based (JWT)
- **Public/Private**: ACL system with public endpoint allowlist

### Testing Strategy

#### Backend Testing
- **Unit Tests**: `*_test.go` files alongside source files
- **Integration Tests**: API tests in `server/router/api/v1/test/`
- **Table-Driven Tests**: Preferred for multiple test cases
- **Database Testing**: Test with all three database drivers
- **Coverage**: Focus on critical paths and error conditions

#### Frontend Testing
- **Linting**: TypeScript check + ESLint for code quality
- **Manual Testing**: Local dev server validation for UI changes
- **Component Testing**: Visual validation through development

### Git Workflow

#### Commit Conventions
Follow Conventional Commits format:
- `feat(scope): description` - New features
- `fix(scope): description` - Bug fixes
- `chore(scope): description` - Maintenance tasks
- `refactor(scope): description` - Code restructuring
- `test(scope): description` - Test additions/fixes
- `docs(scope): description` - Documentation updates

#### Scopes
- `server` - Backend server code
- `api` - API endpoints and services
- `store` - Data persistence layer
- `web` - Frontend application
- `proto` - Protocol Buffer definitions
- `migration` - Database schema changes

## Domain Context

### Core Entities
- **Memo**: Central note-taking entity with markdown content
- **User**: User accounts with authentication
- **Attachment**: File uploads and media storage
- **MemoRelation**: Graph relationships between memos
- **Activity**: User activity logging and audit trail
- **Inbox**: Temporary items for processing
- **Reaction**: Emoji reactions on memos
- **WorkspaceSetting**: Global configuration
- **UserSetting**: User preferences
- **IdentityProvider**: OAuth/SSO integration

### Key Features
- **Markdown Support**: Rich text editing with markdown syntax
- **File Attachments**: Image and file upload capabilities
- **Memo Relationships**: Link memos together (references, tags)
- **Multi-User**: User management and collaboration
- **RSS Feeds**: Content syndication
- **Search**: Full-text search capabilities
- **Themes**: Customizable UI themes
- **Internationalization**: Multi-language support

### Business Logic
- **Privacy-First**: Self-hosted, no external data sharing
- **Lightweight**: Minimal resource requirements
- **Extensible**: Plugin system for custom functionality
- **Cross-Platform**: Web-based with mobile-responsive design

## Important Constraints

### Technical Constraints
- **Database Compatibility**: Must support SQLite, MySQL, and PostgreSQL
- **Performance**: Fast loading and responsive UI
- **Security**: Secure authentication and data protection
- **Backward Compatibility**: Schema migrations must be non-breaking
- **Resource Usage**: Minimal memory and CPU footprint

### Business Constraints
- **Self-Hosted**: No external service dependencies for core functionality
- **Open Source**: MIT licensed, community-driven development
- **Privacy**: No data collection or telemetry
- **Simplicity**: Easy to deploy and maintain

### Regulatory Constraints
- **Data Protection**: GDPR compliance considerations for EU users
- **Security**: Secure handling of user data and authentication

## External Dependencies

### Core Dependencies
- **Protocol Buffers**: API contract definition and code generation
- **gRPC Ecosystem**: Service communication and REST gateway
- **Database Drivers**: SQLite, MySQL, PostgreSQL drivers
- **Authentication**: JWT and session management

### Frontend Dependencies
- **React Ecosystem**: UI framework and related tools
- **Build Tools**: Vite for development and production builds
- **UI Libraries**: Radix UI for accessible components
- **Styling**: Tailwind CSS for utility-first styling

### Development Tools
- **buf**: Protocol Buffer tooling and validation
- **golangci-lint**: Go code analysis and linting
- **ESLint/Prettier**: Frontend code quality and formatting
- **Docker**: Containerization and deployment

### Optional Integrations
- **OAuth/SSO**: Identity provider integrations
- **File Storage**: S3-compatible storage for attachments
- **Webhooks**: External service notifications
