// Test OpenRouter integration
// Run with: node test-openrouter.js

require('dotenv').config();

console.log('🧪 Testing OpenRouter Integration');
console.log('================================');
console.log('');

// Check if the API key exists
const apiKey = process.env.OPENROUTER_API_KEY;
if (!apiKey) {
    console.log('❌ OPENROUTER_API_KEY not found in .env file');
    console.log('   Please add: OPENROUTER_API_KEY=sk-or-v1-your_key_here');
    return;
}

console.log('✅ OpenRouter API Key found');
console.log('📏 Length:', apiKey.length);
console.log('🔑 Starts with:', apiKey.substring(0, 10) + '...');
console.log('');

const axios = require('axios');

// Test OpenRouter API
async function testOpenRouter() {
    try {
        console.log('🧪 Testing OpenRouter API...');
        
        const response = await axios.post(
            'https://openrouter.ai/api/v1/chat/completions',
            {
                model: 'openrouter/mistral-7b-instruct',
                messages: [
                    {
                        role: 'user',
                        content: 'Hello! Can you help me parse this task: "Call John tomorrow at 2pm about the project update"'
                    }
                ],
                max_tokens: 200,
                temperature: 0.1,
                top_p: 0.9,
            },
            {
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json',
                    'HTTP-Referer': 'http://localhost:3000',
                    'X-Title': 'TaskMate AI Service'
                },
                timeout: 30000
            }
        );

        console.log('✅ SUCCESS! OpenRouter is working');
        console.log('🤖 Response:', response.data.choices[0]?.message?.content);
        console.log('');
        
        // Test task parsing
        console.log('🧪 Testing task parsing...');
        const taskResponse = await axios.post(
            'https://openrouter.ai/api/v1/chat/completions',
            {
                model: 'openrouter/mistral-7b-instruct',
                messages: [
                    {
                        role: 'user',
                        content: `You are a task parsing assistant. Parse this natural language input and extract task information.

Input: "Call John tomorrow at 2pm about the project update"

Extract and return ONLY a valid JSON object with these exact fields:
- task: what needs to be done
- person: who it's about (if mentioned)
- datetime: when it's due (in ISO 8601 format like 2025-01-15T09:00:00.000Z)
- type: task category (event, follow-up, communication, or reminder)

Return only the JSON object, no additional text.`
                    }
                ],
                max_tokens: 200,
                temperature: 0.1,
                top_p: 0.9,
            },
            {
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json',
                    'HTTP-Referer': 'http://localhost:3000',
                    'X-Title': 'TaskMate AI Service'
                },
                timeout: 30000
            }
        );

        const content = taskResponse.data.choices[0]?.message?.content;
        console.log('✅ Task parsing successful!');
        console.log('📝 Parsed result:', content);
        
        // Try to extract and parse JSON
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                const parsed = JSON.parse(jsonMatch[0]);
                console.log('✅ JSON parsing successful!');
                console.log('📋 Task:', parsed.task);
                console.log('👤 Person:', parsed.person);
                console.log('⏰ DateTime:', parsed.datetime);
                console.log('🏷️  Type:', parsed.type);
            } catch (e) {
                console.log('⚠️  JSON parsing failed:', e.message);
            }
        } else {
            console.log('⚠️  No JSON found in response');
        }

    } catch (error) {
        console.log('❌ OpenRouter test failed:', error.message);
        if (error.response) {
            console.log('Status:', error.response.status);
            console.log('Data:', error.response.data);
        }
    }
}

// Run the test
testOpenRouter();




