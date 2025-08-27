# TaskMate OpenAI Integration Module

This document explains how to set up and use the OpenAI Integration Module for natural language task creation.

## 🚀 Features

- **Natural Language Processing**: Convert human language to structured task data using OpenAI's GPT-3.5-turbo
- **Smart Date Parsing**: Automatically extract dates from phrases like "next week", "in 3 days"
- **Person Recognition**: Identify people mentioned in tasks
- **Task Type Classification**: Automatically categorize tasks (event, follow-up, communication, etc.)
- **Fallback System**: Rule-based parsing when OpenAI is unavailable

## 🛠️ Setup Instructions

### 1. Get OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an account or sign in
3. Go to [API Keys](https://platform.openai.com/api-keys)
4. Create a new API key
5. Copy the API key (starts with "sk-")

### 2. Configure Environment Variables

Create a `.env` file in your backend directory:

```bash
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/taskmate

# JWT Secret
JWT_SECRET=your_jwt_secret_here

# OpenAI API Key (Costs: $0.002 per 1K tokens)
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Install Dependencies

```bash
cd backend
npm install axios
```

## 📡 API Endpoints

### 1. AI Task Creation (Authenticated)
**POST** `/api/tasks/ai`

Creates a task from natural language input.

**Request Body:**
```json
{
    "naturalLanguageInput": "Remind me to check in with Leila next week"
}
```

**Response:**
```json
{
    "task": {
        "id": "uuid",
        "name": "check in with Leila",
        "description": "AI-generated task from: \"Remind me to check in with Leila next week\"",
        "dueAt": "2025-01-15T09:00:00.000Z",
        "status": "pending",
        "priority": "Medium priority",
        "contact": "Leila"
    },
    "parsed": {
        "task": "check in with Leila",
        "person": "Leila",
        "datetime": "2025-01-15T09:00:00.000Z",
        "type": "follow-up"
    },
    "message": "Task created successfully from natural language input"
}
```

### 2. AI Test Endpoint (No Auth Required)
**POST** `/api/tasks/ai/test`

Test the AI parsing without creating a task.

**Request Body:**
```json
{
    "naturalLanguageInput": "Anniversary dinner with my wife in 10 days"
}
```

**Response:**
```json
{
    "input": "Anniversary dinner with my wife in 10 days",
    "parsed": {
        "task": "Anniversary dinner with my wife",
        "person": "my wife",
        "datetime": "2025-01-15T09:00:00.000Z",
        "type": "event"
    },
    "message": "AI parsing successful"
}
```

## 🧠 How It Works

### 1. Natural Language Input
Users can input tasks in natural language:
- "Remind me to check in with Leila next week"
- "Anniversary dinner with my wife in 10 days"
- "Call mom tomorrow"
- "Meeting with team in 2 weeks"

### 2. AI Processing
The system extracts:
- **Task**: What needs to be done
- **Person**: Who it's about
- **Datetime**: When it's due
- **Type**: Category of the task

### 3. Database Storage
Creates a structured task in your database with:
- Task name and description
- Due date and time
- Contact person (if mentioned)
- Priority and status

## 🔧 Supported Time Patterns

- "next week" → 7 days from now
- "next month" → 30 days from now
- "tomorrow" → 1 day from now
- "in X days" → X days from now
- "in X weeks" → X weeks from now

## 🎯 Task Type Classification

- **event**: dinner, lunch, meeting, appointment
- **follow-up**: check, follow up, review
- **communication**: call, message, email
- **reminder**: default type for other tasks

## 🚨 Error Handling

- Falls back to rule-based parsing if AI fails
- Comprehensive error logging
- User-friendly error messages
- Graceful degradation

## 💡 Usage Examples

### Frontend Integration

```javascript
// Example: Creating a task with natural language
const createAITask = async (naturalLanguageInput) => {
    try {
        const response = await fetch('/api/tasks/ai', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ naturalLanguageInput })
        });
        
        const result = await response.json();
        console.log('Task created:', result.task);
        console.log('Parsed data:', result.parsed);
        
    } catch (error) {
        console.error('Error creating AI task:', error);
    }
};

// Usage examples
createAITask("Remind me to call mom tomorrow");
createAITask("Team meeting next week");
createAITask("Follow up with John in 3 days");
```

## 🔒 Security Features

- JWT authentication required for task creation
- Input validation and sanitization
- Rate limiting (handled by Hugging Face)
- Secure API token storage

## 📊 Performance

- **Free Tier**: 30,000 requests/month
- **Response Time**: ~200-500ms
- **Fallback**: Instant rule-based parsing
- **Caching**: Can be implemented for repeated patterns

## 🚀 Future Enhancements

- [ ] Machine learning model training on user data
- [ ] Smart priority suggestions
- [ ] Recurring task detection
- [ ] Multi-language support
- [ ] Context-aware suggestions
- [ ] Integration with calendar systems

## 🆘 Troubleshooting

### Common Issues

1. **API Token Invalid**
   - Verify your Hugging Face token
   - Check token permissions
   - Ensure token is in .env file

2. **Rate Limit Exceeded**
   - Free tier: 30,000 requests/month
   - Upgrade to paid plan if needed
   - Implement local caching

3. **Parsing Errors**
   - Check input format
   - Verify supported time patterns
   - Review error logs

### Debug Mode

Enable debug logging by setting:
```bash
DEBUG=ai-service npm run dev
```

## 📞 Support

For issues or questions:
1. Check this README
2. Review error logs
3. Test with `/ai/test` endpoint
4. Verify environment configuration

---

**Happy AI-powered task management! 🎉**
