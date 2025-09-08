import axios from 'axios';
import { aiConfig } from '../config/ai';

export interface ParsedTask {
  task: string;
  description?: string;
  person?: string;
  datetime?: string;
  type: 'event' | 'follow-up' | 'communication' | 'reminder';
  priority?: 'High priority' | 'Medium priority' | 'Low priority';
  status?: 'pending' | 'in_progress' | 'completed';
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
    const tomorrowDate = new Date(currentDate);
    tomorrowDate.setDate(tomorrowDate.getDate() + 1);
    const tomorrowDateString = tomorrowDate.toISOString().split('T')[0];
    
    const prompt = `You are a task parsing assistant. Parse this natural language input and extract task information.

IMPORTANT: Today's date is ${currentDateString} (${currentDate.toDateString()}).
Tomorrow's date is ${tomorrowDateString} (${tomorrowDate.toDateString()}).

Input: "${input}"

Extract and return ONLY a valid JSON object with these exact fields:
- task: clean, concise title (1-2 words like "Meeting", "Call", "Running", "Email", "Review", "Buy", "Send")
- description: clean description without dates, times, priority, or status (e.g., "with John about project", "Sarah to confirm appointment", "weekly report to team")
- person: who it's about (if mentioned)
- datetime: when it's due (in ISO 8601 format like 2025-08-26T14:00:00.000Z)
- type: task category (event, follow-up, communication, or reminder)
- priority: task priority (High priority, Medium priority, or Low priority)
- status: task status (pending, in_progress, or completed)

TITLE EXTRACTION RULES:
- Extract the main action/activity as a clean 1-2 word title
- Examples: "Call Sarah tomorrow" → task: "Call", description: "Sarah"
- Examples: "Meeting with team" → task: "Meeting", description: "with team"
- Examples: "Send report" → task: "Send", description: "report"
- Examples: "Buy groceries" → task: "Buy", description: "groceries"

DESCRIPTION RULES:
- Keep only the essential details about what needs to be done
- Remove all dates, times, priority words, and status words
- Focus on WHO and WHAT, not WHEN or HOW URGENT
- Do NOT include trailing commas in the description
- Examples: "Call Sarah tomorrow at 2 PM, urgent" → description: "Sarah"
- Examples: "Meeting with John about project, high priority" → description: "with John about project"
- Examples: "Meeting with safouane," → description: "with safouane"

CRITICAL DATE RULES:
- When the user says "today", use today's date (${currentDateString})
- When the user says "tomorrow", use tomorrow's date (${tomorrowDateString})
- Always use the current year (${currentDate.getFullYear()}) unless explicitly specified otherwise
- If no specific date is mentioned, default to tomorrow (${tomorrowDateString})
- Always include a datetime field - never leave it empty

PRIORITY RULES:
- "urgent", "asap", "critical", "high priority" → "High priority"
- "medium priority", "normal priority" → "Medium priority"  
- "low priority", "when possible", "sometime" → "Low priority"
- If no priority mentioned, default to "Medium priority"

STATUS RULES:
- "in progress", "working on", "doing", "started" → "in_progress"
- "done", "completed", "finished", "completed" → "completed"
- "pending", "to do", "need to", "should" → "pending"
- If no status mentioned, default to "pending"

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

    // Extract clean title and description
    let task: string = input;
    let description: string | undefined;
    
    // Extract main action as title
    if (lowerInput.includes('call')) {
      task = 'Call';
    } else if (lowerInput.includes('meeting')) {
      task = 'Meeting';
    } else if (lowerInput.includes('email') || lowerInput.includes('send')) {
      task = 'Email';
    } else if (lowerInput.includes('buy') || lowerInput.includes('purchase')) {
      task = 'Buy';
    } else if (lowerInput.includes('run') || lowerInput.includes('running')) {
      task = 'Running';
    } else if (lowerInput.includes('review')) {
      task = 'Review';
    } else if (lowerInput.includes('create') || lowerInput.includes('make')) {
      task = 'Create';
    } else if (lowerInput.includes('update') || lowerInput.includes('edit')) {
      task = 'Update';
    } else if (lowerInput.includes('delete') || lowerInput.includes('remove')) {
      task = 'Delete';
    } else if (lowerInput.includes('read') || lowerInput.includes('check')) {
      task = 'Read';
    } else if (lowerInput.includes('write') || lowerInput.includes('draft')) {
      task = 'Write';
    }

    // Extract description (remove dates, times, priority, status words)
    let cleanDescription = input
      .replace(/\b(tomorrow|today|yesterday|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b/gi, '')
      .replace(/\b(at|on|in)\s+\d{1,2}(:\d{2})?\s*(am|pm)?\b/gi, '')
      .replace(/\b(urgent|asap|critical|high priority|medium priority|low priority|when possible|sometime)\b/gi, '')
      .replace(/\b(in progress|working on|doing|started|done|completed|finished|pending|to do|need to|should)\b/gi, '')
      .replace(/\b(call|meeting|email|buy|run|review|create|update|delete|read|write)\b/gi, '')
      .replace(/\s+/g, ' ')
      .replace(/,\s*$/, '') // Remove trailing comma
      .trim();

    if (cleanDescription && cleanDescription !== input) {
      description = cleanDescription;
    }

    // Parse priority from input
    let priority: ParsedTask['priority'] = 'Medium priority';
    if (lowerInput.includes('urgent') || lowerInput.includes('asap') || lowerInput.includes('critical') || lowerInput.includes('high priority')) {
      priority = 'High priority';
    } else if (lowerInput.includes('low priority') || lowerInput.includes('when possible') || lowerInput.includes('sometime')) {
      priority = 'Low priority';
    }

    // Parse status from input
    let status: ParsedTask['status'] = 'pending';
    if (lowerInput.includes('in progress') || lowerInput.includes('working on') || lowerInput.includes('doing') || lowerInput.includes('started')) {
      status = 'in_progress';
    } else if (lowerInput.includes('done') || lowerInput.includes('completed') || lowerInput.includes('finished')) {
      status = 'completed';
    }

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
    } else {
      // No specific date mentioned, default to tomorrow
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(9, 0, 0, 0); // Default to 9 AM tomorrow
      datetime = tomorrow.toISOString();
    }

    return {
      task,
      description,
      type,
      person,
      datetime,
      priority,
      status
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

    // Normalize the priority field
    let priority: ParsedTask['priority'] = 'Medium priority';
    if (parsed.priority) {
      const lowerPriority = parsed.priority.toLowerCase();
      if (lowerPriority.includes('high')) {
        priority = 'High priority';
      } else if (lowerPriority.includes('low')) {
        priority = 'Low priority';
      }
    }

    // Normalize the status field
    let status: ParsedTask['status'] = 'pending';
    if (parsed.status) {
      const lowerStatus = parsed.status.toLowerCase();
      if (lowerStatus.includes('progress') || lowerStatus.includes('doing')) {
        status = 'in_progress';
      } else if (lowerStatus.includes('done') || lowerStatus.includes('completed') || lowerStatus.includes('finished')) {
        status = 'completed';
      }
    }

    return {
      task: parsed.task,
      description: parsed.description || undefined,
      person: parsed.person || undefined,
      datetime: parsed.datetime || undefined,
      type,
      priority,
      status
    };
  }
}
