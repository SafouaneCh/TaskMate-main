const axios = require('axios');

// Test the GitHub Models integration
async function testGitHubModels() {
  try {
    console.log('🧪 Testing GitHub Models Integration...\n');
    
    const response = await axios.post('http://localhost:8000/tasks/ai/test', {
      naturalLanguageInput: "Schedule a meeting with John tomorrow at 2 PM to discuss the project timeline"
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Success! Response:');
    console.log(JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    console.error('❌ Error testing GitHub Models:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

// Run the test
testGitHubModels();
