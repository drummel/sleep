// Analytics wrapper for OperatorStack events
// In production, this would use window.OperatorStack
// For now, we log events and provide a typed interface

export type AnalyticsEvent =
  | { name: 'quiz_start'; data: { source: string } }
  | { name: 'quiz_question_answered'; data: { question_number: number; answer: string } }
  | { name: 'quiz_abandoned'; data: { last_question: number; time_spent_seconds: number } }
  | { name: 'quiz_complete'; data: { chronotype: string; time_spent_seconds: number; entry_point: string } }
  | { name: 'email_signup'; data: { chronotype: string; track: string } }
  | { name: 'share_card_click'; data: { platform: string; chronotype: string; card_type: string } }
  | { name: 'feature_vote'; data: { features: string[]; chronotype: string } }
  | { name: 'app_interest_click'; data: { chronotype: string; track: string } }
  | { name: 'referral_share'; data: { method: string } }
  | { name: 'compatibility_tool_opened'; data: { source: string } }
  | { name: 'compatibility_chronotype_selected'; data: { position: string; chronotype: string } }
  | { name: 'compatibility_card_generated'; data: { pairing: string } }
  | { name: 'compatibility_card_shared'; data: { platform: string; pairing: string } }
  | { name: 'partner_invite_sent'; data: { method: string } }
  | { name: 'partner_quiz_started'; data: { referrer_chronotype: string } }
  | { name: 'partner_mode_interest'; data: { pairing: string } }

const eventLog: AnalyticsEvent[] = []

export function trackEvent(event: AnalyticsEvent): void {
  eventLog.push(event)

  // OperatorStack integration point
  if (typeof window !== 'undefined' && (window as any).OperatorStack) {
    ;(window as any).OperatorStack.track(event.name, event.data)
  }

  if (process.env.NODE_ENV === 'development') {
    console.log(`[Analytics] ${event.name}`, event.data)
  }
}

export function getEventLog(): AnalyticsEvent[] {
  return [...eventLog]
}

export function clearEventLog(): void {
  eventLog.length = 0
}

// Email capture (OperatorStack waitlist integration)
export interface WaitlistOptions {
  email: string
  waitlist_id: string
  metadata?: Record<string, string>
}

export async function joinWaitlist(options: WaitlistOptions): Promise<{ success: boolean; referral_code: string }> {
  if (typeof window !== 'undefined' && (window as any).OperatorStack) {
    return (window as any).OperatorStack.joinWaitlist(options)
  }

  // Mock response for development/testing
  const code = 'ref_' + Math.random().toString(36).substring(2, 10)
  return { success: true, referral_code: code }
}

// Feature survey submission
export interface SurveySubmission {
  email?: string
  chronotype: string
  goal: string
  features: string[]
  feature_count: number
  track: string
  submitted_at: string
}

export async function submitFeatureSurvey(data: SurveySubmission): Promise<{ success: boolean }> {
  if (typeof window !== 'undefined' && (window as any).OperatorStack) {
    return (window as any).OperatorStack.submitForm('frm_feature_interest', data)
  }

  return { success: true }
}

// Share links generation
export function getShareLinks(referralCode: string, opts: { text: string; url: string }) {
  const encodedText = encodeURIComponent(opts.text)
  const encodedUrl = encodeURIComponent(opts.url)

  return {
    twitter: `https://twitter.com/intent/tweet?text=${encodedText}&url=${encodedUrl}`,
    whatsapp: `https://wa.me/?text=${encodedText}%20${encodedUrl}`,
    copy: opts.url,
  }
}
