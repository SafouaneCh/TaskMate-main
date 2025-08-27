// Simple test script for OpenAI integration
// Run with: node test-ai.js

const axios = require('axios');

// Test the OpenAI parsing directly
async function testOpenAI() {
    const apiKey = process.env.OPENAI_API_KEY;
    
    if (!apiKey) {
        console.log('❌ No OPENAI_API_KEY found in environment variables');
        console.log('Please create a .env file with your OpenAI API key');
        return;
    }

    console.log('🧠 Testing OpenAI Integration...\n');

    const testInputs = [
        "Call mom tomorrow",
        "Meeting with John next week",
        "Follow up with client about project proposal in 3 days",
        "Anniversary dinner with my wife next month"
    ];

    for (const input of testInputs) {
        console.log(`📝 Input: "${input}"`);
        
        try {
            const response = await axios.post(
                'https://api.openai.com/v1/chat/completions',
                {
                    model: 'gpt-3.5-turbo',
                    messages: [
                        {
                            role: "system",
                            content: "You are a task parsing assistant. Extract task information from user input and return ONLY a valid JSON object with these exact fields: task (what to do), person (who it's about), datetime (when it's due in ISO format), type (task category: event, follow-up, communication, or reminder)."
                        },
                        {
                            role: "user",
                            content: input
                        }
                    ],
                    temperature: 0.1,
                    max_tokens: 200
                },
                {
                    headers: {
                        'Authorization': `Bearer ${apiKey}`,
                        'Content-Type': 'application/json'
                    },
                    timeout: 15000
                }
            );

            console.log('✅ OpenAI Response:', response.data.choices[0].message.content);
            
        } catch (error) {
            console.log('❌ Error:', error.message);
        }
        
        console.log('---\n');
    }
}

// Run the test
testOpenAI().catch(console.error);
