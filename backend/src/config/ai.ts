import dotenv from 'dotenv';

dotenv.config();

export const aiConfig = {
  github: {
    apiUrl: 'https://models.github.ai/inference',
    apiKey: process.env.GITHUB_TOKEN || '',
    model: 'openai/gpt-4o',
  },
  primaryService: 'github' as const,
};
