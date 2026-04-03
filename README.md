# @wave-av/workflow-sdk

Official SDK for building and executing workflows on the WAVE platform.

## Installation

```bash
npm install @wave-av/workflow-sdk
```

## Quick start

```typescript
import { WaveWorkflowClient } from '@wave-av/workflow-sdk';

const client = new WaveWorkflowClient({
  apiKey: process.env.WAVE_API_KEY!,
  organizationId: 'org_123',
});

const execution = await client.execute('my-workflow', {
  input_params: { environment: 'production' },
});

const result = await client.waitForCompletion(execution.id);
console.log('Result:', result.status);
```

See the [full documentation](https://www.npmjs.com/package/@wave-av/workflow-sdk) for the builder API, real-time events, validation, and more.

## License

MIT
