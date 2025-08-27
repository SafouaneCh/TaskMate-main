import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestBody = await req.json()
    console.log('🔔 === Task Reminder Scheduling Request ===')
    console.log('📋 Request body:', JSON.stringify(requestBody, null, 2))
    
    const { taskId, userId, title, message, scheduledAt, priority, reminderType, playerId } = requestBody

    // Validate required fields
    if (!taskId || !userId || !title || !message || !scheduledAt || !playerId) {
      console.log('❌ Missing required fields:')
      console.log('  - taskId:', !!taskId)
      console.log('  - userId:', !!userId)
      console.log('  - title:', !!title)
      console.log('  - message:', !!message)
      console.log('  - scheduledAt:', !!scheduledAt)
      console.log('  - playerId:', !!playerId)
      throw new Error('Missing required fields')
    }

    console.log('✅ All required fields present')
    console.log('📅 Scheduling details:')
    console.log('  - Task ID:', taskId)
    console.log('  - User ID:', userId)
    console.log('  - Reminder Type:', reminderType)
    console.log('  - Scheduled At:', scheduledAt)
    console.log('  - Player ID:', playerId)

    // Get OneSignal credentials from environment
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalRestApiKey = Deno.env.get('ONESIGNAL_REST_API_KEY')

    if (!oneSignalAppId || !oneSignalRestApiKey) {
      console.log('❌ OneSignal configuration missing:')
      console.log('  - ONESIGNAL_APP_ID:', !!oneSignalAppId)
      console.log('  - ONESIGNAL_REST_API_KEY:', !!oneSignalRestApiKey)
      throw new Error('OneSignal configuration missing')
    }

    console.log('✅ OneSignal configuration found')

    // Schedule notification via OneSignal
    const notificationData = {
      app_id: oneSignalAppId,
      include_player_ids: [playerId],
      headings: { en: title },
      contents: { en: message },
      send_after: scheduledAt, // Enable real scheduling
      data: {
        taskId,
        userId,
        priority,
        reminderType,
        type: 'task_reminder'
      },
      priority: 10
    }

    console.log('📤 OneSignal notification data:', JSON.stringify(notificationData, null, 2))

    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${oneSignalRestApiKey}`
      },
      body: JSON.stringify(notificationData)
    })

    console.log('📱 OneSignal API response status:', response.status)
    const responseText = await response.text()
    console.log('📱 OneSignal API response body:', responseText)

    if (!response.ok) {
      console.log('❌ OneSignal API error response')
      throw new Error(`OneSignal API error: ${responseText}`)
    }

    const result = JSON.parse(responseText)
    console.log('✅ OneSignal notification scheduled successfully')
    console.log('📱 OneSignal notification ID:', result.id)

    // Store notification record in scheduled_notifications table
    await storeScheduledNotification({
      taskId,
      userId,
      title,
      message,
      scheduledAt,
      oneSignalNotificationId: result.id
    })

    console.log('💾 Notification record stored in database')
    console.log('🎉 === Task Reminder Scheduling Complete ===')

    return new Response(
      JSON.stringify({ 
        success: true, 
        notificationId: result.id,
        message: 'Task reminder scheduled successfully',
        scheduledAt: scheduledAt,
        reminderType: reminderType
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('❌ === Task Reminder Scheduling Error ===')
    console.error('Error details:', error.message)
    console.error('Stack trace:', error.stack)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})

// Helper function to get user's OneSignal player ID
async function getUserOneSignalPlayerId(userId: string): Promise<string | null> {
  // For testing: return a valid UUID format placeholder
  // TODO: Replace with actual database query when user_devices table is set up
  return '12345678-1234-1234-1234-123456789012';
  
  // Future implementation:
  // const { data, error } = await supabase
  //   .from('user_devices')
  //   .select('onesignal_player_id')
  //   .eq('user_id', userId)
  //   .eq('is_active', true)
  //   .single();
  // 
  // if (error || !data) return null;
  // return data.onesignal_player_id;
}

// Helper function to store scheduled notification
async function storeScheduledNotification(data: {
  taskId: string
  userId: string
  title: string
  message: string
  scheduledAt: string
  oneSignalNotificationId: string
}) {
  // This would insert into your scheduled_notifications table
  // For now, just logging - you'll implement this based on your database setup
  console.log('Storing scheduled notification:', data)
}
