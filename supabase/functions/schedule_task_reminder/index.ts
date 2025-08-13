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
    console.log('Received request body:', JSON.stringify(requestBody, null, 2))
    
    const { taskId, userId, title, message, scheduledAt, priority, reminderType, playerId } = requestBody

    // Validate required fields
    if (!taskId || !userId || !title || !message || !scheduledAt || !playerId) {
      console.log('Missing fields - taskId:', !!taskId, 'userId:', !!userId, 'title:', !!title, 'message:', !!message, 'scheduledAt:', !!scheduledAt, 'playerId:', !!playerId)
      throw new Error('Missing required fields')
    }

    // Get OneSignal credentials from environment
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalRestApiKey = Deno.env.get('ONESIGNAL_REST_API_KEY')

    if (!oneSignalAppId || !oneSignalRestApiKey) {
      throw new Error('OneSignal configuration missing')
    }

    // Use playerId from request instead of placeholder
    // const playerId = await getUserOneSignalPlayerId(userId)
    
    // if (!playerId) {
    //   throw new Error('User device not found')
    // }

    // Schedule notification via OneSignal
    const notificationData = {
      app_id: oneSignalAppId,
      include_player_ids: [playerId],
      headings: { en: title },
      contents: { en: message },
      // Remove send_after to send immediately
      // send_after: scheduledAt,
      data: {
        taskId,
        userId,
        priority,
        reminderType,
        type: 'task_reminder'
      },
      // Removed android_channel_id temporarily - will add back after creating the channel
      priority: 10
    }

    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${oneSignalRestApiKey}`
      },
      body: JSON.stringify(notificationData)
    })

    console.log('OneSignal API response status:', response.status)
    const responseText = await response.text()
    console.log('OneSignal API response body:', responseText)

    if (!response.ok) {
      throw new Error(`OneSignal API error: ${responseText}`)
    }

    const result = JSON.parse(responseText)

    // Store notification record in scheduled_notifications table
    await storeScheduledNotification({
      taskId,
      userId,
      title,
      message,
      scheduledAt,
      oneSignalNotificationId: result.id
    })

    return new Response(
      JSON.stringify({ 
        success: true, 
        notificationId: result.id,
        message: 'Task reminder scheduled successfully' 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error scheduling task reminder:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
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
