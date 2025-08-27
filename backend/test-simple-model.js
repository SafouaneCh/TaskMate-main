// Simple test with a guaranteed accessible model
// Run with: node test-simple-model.js

require('dotenv').config();
const axios = require('axios');

async function testSimpleModel() {
    const apiKey = process.env.HUGGINGFACE_API_KEY;
    
    if (!apiKey) {
        console.error('❌ HUGGINGFACE_API_KEY not found');
        return;
    }
    
    console.log('🔑 API Key found');
    
    // Try the simplest possible model first
    const models = [
        'distilgpt2',           // Should work
        'gpt2',                 // Might need terms acceptance
        'EleutherAI/gpt-neo-125M', // Alternative
        'microsoft/DialoGPT-small'  // Conversational
    ];
    
    for (const model of models) {
        console.log(`\n🤖 Testing model: ${model}`);
        
        try {
            const response = await axios.post(
                `https://api-inference.huggingface.co/models/${model}`,
                {
                    inputs: "Hello, this is a test.",
                    parameters: {
                        max_new_tokens: 20,
                        temperature: 0.7,
                        do_sample: true,
                        return_full_text: false
                    }
                },
                {
                    headers: {
                        'Authorization': `Bearer ${apiKey}`,
                        'Content-Type': 'application/json'
                    },
                    timeout: 15000
                }
            );
            
            console.log('✅ SUCCESS with model:', model);
            console.log('📊 Response:', JSON.stringify(response.data, null, 2));
            
            // If this model works, use it for the main test
            console.log(`\n🎯 Model ${model} is working! Let's test task parsing:`);
            await testTaskParsing(model, apiKey);
            break;
            
        } catch (error) {
            console.log(`❌ Failed with ${model}:`, error.message);
            if (error.response) {
                console.log('Status:', error.response.status);
                console.log('Data:', error.response.data);
            }
        }
    }
}

async function testTaskParsing(model, apiKey) {
    const testInput = "Remind me to call mom tomorrow";
    
    try {
        const response = await axios.post(
            `https://api-inference.huggingface.co/models/${model}`,
            {
                inputs: `Parse this task: "${testInput}". Return JSON with task, person, datetime, type.`,
                parameters: {
                    max_new_tokens: 100,
                    temperature: 0.3,
                    do_sample: true,
                    return_full_text: false
                }
            },
            {
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 15000
            }
        );
        
        console.log('✅ Task parsing successful!');
        console.log('📝 Generated text:', response.data[0]?.generated_text);
        
    } catch (error) {
        console.log('❌ Task parsing failed:', error.message);
    }
}

testSimpleModel().catch(console.error);
