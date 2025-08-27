// Test script to check API key with different Hugging Face endpoints
// Run with: node test-direct-api.js

require('dotenv').config();
const axios = require('axios');

async function testDirectAPI() {
    const apiKey = process.env.HUGGINGFACE_API_KEY;
    
    if (!apiKey) {
        console.error('❌ HUGGINGFACE_API_KEY not found');
        return;
    }
    
    console.log('🔑 Testing API key:', apiKey.substring(0, 10) + '...');
    console.log('');
    
    // Test 1: Check user profile (different endpoint)
    console.log('🧪 Test 1: Checking user profile...');
    try {
        const response = await axios.get('https://huggingface.co/api/whoami', {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'User-Agent': 'TaskMate/1.0'
            }
        });
        console.log('✅ User profile successful!');
        console.log('👤 User:', response.data.name);
        console.log('📧 Email:', response.data.email);
    } catch (error) {
        console.error('❌ User profile failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
    }
    
    console.log('');
    
    // Test 2: Check if the key has inference API access
    console.log('🧪 Test 2: Checking inference API access...');
    try {
        const response = await axios.get('https://api-inference.huggingface.co/models', {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'User-Agent': 'TaskMate/1.0'
            }
        });
        console.log('✅ Inference API access successful!');
        console.log('📊 Available models count:', response.data.length || 'Unknown');
    } catch (error) {
        console.error('❌ Inference API access failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
    }
    
    console.log('');
    
    // Test 3: Try a simple text classification model
    console.log('🧪 Test 3: Testing simple text classification...');
    try {
        const response = await axios.post(
            'https://api-inference.huggingface.co/models/distilbert-base-uncased',
            {
                inputs: "I love this movie!"
            },
            {
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json',
                    'User-Agent': 'TaskMate/1.0'
                },
                timeout: 30000
            }
        );
        console.log('✅ Text classification successful!');
        console.log('📊 Response type:', typeof response.data);
        console.log('📊 Response preview:', JSON.stringify(response.data).substring(0, 100) + '...');
    } catch (error) {
        console.error('❌ Text classification failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
    }
}

// Run the test
testDirectAPI().catch(console.error);
