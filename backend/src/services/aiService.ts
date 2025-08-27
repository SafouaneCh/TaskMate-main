import axios from 'axios';
import { aiConfig } from '../config/ai';

export interface ParsedTask {
  task: string;
  person?: string;
  datetime?: string;
  type: 'event' | 'follow-up' | 'communication' | 'reminder';
}

export class AIService {
  private githubConfig = aiConfig.github;

  async parseNaturalLanguage(input: string): Promise<ParsedTask> {
    try {
      // Use GitHub's hosted GPT-4o for parsing
      if (this.githubConfig.apiKey) {
        try {
          return await this.parseWithGitHub(input);
        } catch (error) {
          console.log('GitHub Models failed, using rule-based parsing...');
        }
      }

      // Fallback to rule-based parsing
      return this.parseWithRules(input);
    } catch (error) {
      console.error('AI parsing failed, using rule-based fallback:', error);
      return this.parseWithRules(input);
    }
  }

  private async parseWithGitHub(input: string): Promise<ParsedTask> {
    const currentDate = new Date();
    const currentDateString = currentDate.toISOString().split('T')[0]; // YYYY-MM-DD format
    
    const prompt = `You are a task parsing assistant. Parse this natural language input and extract task information.

IMPORTANT: Today's date is ${currentDateString} (${currentDate.toDateString()}).

Input: "${input}"

Extract and return ONLY a valid JSON object with these exact fields:
- task: what needs to be done
- person: who it's about (if mentioned)
- datetime: when it's due (in ISO 8601 format like 2025-08-26T14:00:00.000Z)
- type: task category (event, follow-up, communication, or reminder)

When the user says "today", use today's date (${currentDateString}).
When the user says "tomorrow", use tomorrow's date.
Always use the current year (${currentDate.getFullYear()}) unless explicitly specified otherwise.

Return only the JSON object, no additional text.`;

    const response = await axios.post(
      `${this.githubConfig.apiUrl}/chat/completions`,
      {
        model: this.githubConfig.model,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 200,
        temperature: 0.1,
        top_p: 0.9,
      },
      {
        headers: {
          'Authorization': `Bearer ${this.githubConfig.apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      }
    );

    const content = response.data.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No content in GitHub Models response');
    }

    // Try to extract JSON from the response
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('No JSON found in GitHub Models response');
    }

    const parsed = JSON.parse(jsonMatch[0]);
    return this.validateAndNormalizeTask(parsed);
  }

  private parseWithRules(input: string): ParsedTask {
    // Simple rule-based parsing as fallback
    const lowerInput = input.toLowerCase();
    
    let type: ParsedTask['type'] = 'reminder';
    if (lowerInput.includes('meeting') || lowerInput.includes('event')) type = 'event';
    else if (lowerInput.includes('follow') || lowerInput.includes('check')) type = 'follow-up';
    else if (lowerInput.includes('call') || lowerInput.includes('email') || lowerInput.includes('message')) type = 'communication';

    // Parse date and time from input
    let datetime: string | undefined;
    let person: string | undefined;

    // Extract person (look for names after "with" or "to")
    const personMatch = input.match(/(?:with|to)\s+([a-zA-Z]+)/i);
    if (personMatch) {
      person = personMatch[1];
    }

    // Parse date and time
    if (lowerInput.includes('today')) {
      const today = new Date();
      
      // Extract time (e.g., "at 14:00", "at 2 PM", "at 2:00")
      const timeMatch = input.match(/at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?/i);
      if (timeMatch) {
        let hour = this.int(timeMatch[1]);
        const minute = timeMatch[2] ? this.int(timeMatch[2]) : 0;
        const ampm = timeMatch[3]?.toLowerCase();
        
        // Handle AM/PM
        if (ampm === 'pm' && hour !== 12) hour += 12;
        if (ampm === 'am' && hour === 12) hour = 0;
        
        // Create a new date object to avoid timezone issues
        const taskDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), hour, minute, 0, 0);
        datetime = taskDate.toISOString();
      } else {
        // No specific time, set to current time
        datetime = today.toISOString();
      }
    } else if (lowerInput.includes('tomorrow')) {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      // Extract time
      const timeMatch = input.match(/at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?/i);
      if (timeMatch) {
        let hour = this.int(timeMatch[1]);
        const minute = timeMatch[2] ? this.int(timeMatch[2]) : 0;
        const ampm = timeMatch[3]?.toLowerCase();
        
        if (ampm === 'pm' && hour !== 12) hour += 12;
        if (ampm === 'am' && hour === 12) hour = 0;
        
        // Create a new date object to avoid timezone issues
        const taskDate = new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate(), hour, minute, 0, 0);
        datetime = taskDate.toISOString();
      } else {
        tomorrow.setHours(9, 0, 0, 0); // Default to 9 AM
        datetime = tomorrow.toISOString();
      }
    }

    return {
      task: input,
      type,
      person,
      datetime
    };
  }

  private int(value: string | undefined): number {
    return value ? parseInt(value, 10) : 0;
  }

  private validateAndNormalizeTask(parsed: any): ParsedTask {
    // Ensure required fields exist
    if (!parsed.task) {
      throw new Error('Task field is required');
    }

    // Normalize the type field
    let type: ParsedTask['type'] = 'reminder';
    if (parsed.type) {
      const lowerType = parsed.type.toLowerCase();
      if (['event', 'follow-up', 'communication', 'reminder'].includes(lowerType)) {
        type = lowerType as ParsedTask['type'];
      }
    }

    return {
      task: parsed.task,
      person: parsed.person || undefined,
      datetime: parsed.datetime || undefined,
      type
    };
  }
}
