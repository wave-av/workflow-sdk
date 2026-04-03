# @wave-av/workflow-sdk

Official SDK for building and executing workflows on the WAVE platform.

## Installation

```bash
npm install @wave-av/workflow-sdk
# or
yarn add @wave-av/workflow-sdk
# or
pnpm add @wave-av/workflow-sdk
```

## Quick start

```typescript
import { WaveWorkflowClient } from '@wave-av/workflow-sdk';

// Create a client
const client = new WaveWorkflowClient({
  apiKey: process.env.WAVE_API_KEY!,
  organizationId: 'org_123',
});

// Execute a workflow
const execution = await client.execute('my-workflow', {
  input_params: {
    environment: 'production',
  },
});

console.log('Execution started:', execution.id);

// Wait for completion
const result = await client.waitForCompletion(execution.id);
console.log('Result:', result.status);
```

## Building workflows

Use the fluent builder API to create workflow definitions:

```typescript
import { WorkflowBuilder } from '@wave-av/workflow-sdk';

const workflow = new WorkflowBuilder('data-pipeline')
  .name('Data Processing Pipeline')
  .description('ETL pipeline for processing analytics data')
  .category('data-processing')
  .version('1.0.0')
  .tags('etl', 'analytics')
  .phase('extract', (phase) =>
    phase
      .description('Extract data from source systems')
      .agent('data-extractor', { source: 'api', endpoint: '/data' })
  )
  .phase('transform', (phase) =>
    phase
      .description('Transform and validate data')
      .agent('data-transformer', { format: 'json' })
      .onFailure('retry')
  )
  .phase('load', (phase) =>
    phase
      .description('Load data to destination')
      .agent('data-loader', { destination: 'database' })
  )
  .timeout(3600)
  .enableCheckpoints()
  .maxRetries(3)
  .build();

// Export as JSON
console.log(JSON.stringify(workflow, null, 2));
```

## API reference

### WaveWorkflowClient

#### Constructor options

```typescript
const client = new WaveWorkflowClient({
  apiKey: string;           // Required: API key for authentication
  organizationId: string;   // Required: Organization ID for tenant isolation
  baseUrl?: string;         // Optional: API base URL (default: https://api.wave.online)
  timeout?: number;         // Optional: Request timeout in ms (default: 30000)
  debug?: boolean;          // Optional: Enable debug logging
});
```

#### Methods

##### Workflow definitions

```typescript
// Get a workflow by slug
const workflow = await client.getWorkflow('my-workflow');

// List all workflows
const { workflows, total } = await client.listWorkflows({
  category: 'devops',
  status: 'active',
  limit: 10,
});
```

##### Executions

```typescript
// Execute a workflow
const execution = await client.execute('my-workflow', {
  input_params: { key: 'value' },
  idempotency_key: 'unique-key',
});

// Get execution status
const status = await client.getExecution(execution.id);

// List executions
const { executions } = await client.listExecutions({
  workflow_id: 'workflow-id',
  status: 'running',
  limit: 20,
});

// Cancel an execution
await client.cancelExecution(execution.id);

// Pause an execution
await client.pauseExecution(execution.id);

// Resume a paused execution
await client.resumeExecution(execution.id);

// Retry a failed execution
await client.retryExecution(execution.id, { from_checkpoint: true });
```

##### Convenience methods

```typescript
// Wait for completion with progress callback
const result = await client.waitForCompletion(execution.id, {
  pollInterval: 2000,  // Poll every 2 seconds
  timeout: 3600000,    // 1 hour timeout
  onProgress: (exec) => {
    console.log(`Status: ${exec.status}, Phase: ${exec.current_phase}`);
  },
});

// Execute and wait in one call
const result = await client.executeAndWait('my-workflow', {
  input_params: { key: 'value' },
});
```

##### Logs

```typescript
// Get execution logs
const { logs } = await client.getLogs(execution.id, {
  level: 'error',
  limit: 100,
});
```

##### Real-time events

```typescript
// Subscribe to execution events
const unsubscribe = client.subscribeToExecution(execution.id);

client.on('execution.started', (event) => {
  console.log('Execution started:', event);
});

client.on('phase.completed', (event) => {
  console.log('Phase completed:', event.data.phase_name);
});

client.on('execution.completed', (event) => {
  console.log('Execution completed in', event.data.duration_ms, 'ms');
  unsubscribe();
});

client.on('error', (error) => {
  console.error('Error:', error);
});
```

## Types

All TypeScript types are exported from the package:

```typescript
import type {
  WorkflowDefinition,
  WorkflowPhase,
  WorkflowAgent,
  WorkflowConfig,
  WorkflowExecution,
  ExecutionStatus,
  ExecutionLog,
  AnyWorkflowEvent,
} from '@wave-av/workflow-sdk';
```

## Validation

The SDK includes Zod schemas for runtime validation:

```typescript
import { WorkflowDefinitionSchema } from '@wave-av/workflow-sdk/types';

const result = WorkflowDefinitionSchema.safeParse(workflowData);
if (!result.success) {
  console.error('Validation errors:', result.error.issues);
}
```

## Error handling

```typescript
try {
  const execution = await client.execute('my-workflow');
} catch (error) {
  if (error.message.includes('API error (404)')) {
    console.error('Workflow not found');
  } else if (error.message.includes('timeout')) {
    console.error('Request timed out');
  } else {
    console.error('Unknown error:', error);
  }
}
```

## Environment variables

| Variable | Description |
|----------|-------------|
| `WAVE_API_KEY` | API key for authentication |
| `WAVE_ORGANIZATION_ID` | Organization ID for tenant isolation |
| `WAVE_API_URL` | Optional: Custom API base URL |

## Related packages

- [@wave-av/sdk](https://www.npmjs.com/package/@wave-av/sdk) — TypeScript SDK (34 API modules)
- [@wave-av/adk](https://www.npmjs.com/package/@wave-av/adk) — Agent Developer Kit
- [@wave-av/mcp-server](https://www.npmjs.com/package/@wave-av/mcp-server) — MCP server for AI tools
- [@wave-av/cli](https://www.npmjs.com/package/@wave-av/cli) — Command-line interface

## License

MIT
