export type ChronotypeId = 'lion' | 'bear' | 'wolf' | 'dolphin'

export interface ChronotypeInfo {
  id: ChronotypeId
  name: string
  emoji: string
  tagline: string
  description: string
  sleepWindow: string
  peakFocus: string
  bestFor: string
  color: string
  bgColor: string
  borderColor: string
  population: string
}

export const chronotypes: Record<ChronotypeId, ChronotypeInfo> = {
  lion: {
    id: 'lion',
    name: 'Lion',
    emoji: '🦁',
    tagline: 'The Early Riser',
    description: 'You\'re at your best before the world wakes up. Lions are morning-dominant, with peak energy and focus in the first half of the day. You naturally wake early, power through mornings, and wind down by evening.',
    sleepWindow: '10:00 PM – 6:00 AM',
    peakFocus: '8:00 AM – 12:00 PM',
    bestFor: 'Deep work before lunch, strategic thinking, exercise at dawn',
    color: 'text-amber-600',
    bgColor: 'bg-amber-50',
    borderColor: 'border-amber-200',
    population: '~15% of people',
  },
  bear: {
    id: 'bear',
    name: 'Bear',
    emoji: '🐻',
    tagline: 'The Solar Tracker',
    description: 'Your rhythm follows the sun. Bears are the most common chronotype — your energy rises after sunrise, peaks mid-morning to early afternoon, and naturally dips in the evening. You thrive on consistent routines.',
    sleepWindow: '11:00 PM – 7:00 AM',
    peakFocus: '10:00 AM – 2:00 PM',
    bestFor: 'Collaborative work, sustained focus blocks, afternoon exercise',
    color: 'text-orange-700',
    bgColor: 'bg-orange-50',
    borderColor: 'border-orange-200',
    population: '~50% of people',
  },
  wolf: {
    id: 'wolf',
    name: 'Wolf',
    emoji: '🐺',
    tagline: 'The Night Owl',
    description: 'Your brain comes alive when the world goes quiet. Wolves peak in the late afternoon and evening, struggle with early mornings, and do their most creative work after dark. You\'re wired for late-night brilliance.',
    sleepWindow: '12:30 AM – 8:30 AM',
    peakFocus: '5:00 PM – 9:00 PM',
    bestFor: 'Creative work at night, brainstorming, evening social energy',
    color: 'text-violet-600',
    bgColor: 'bg-violet-50',
    borderColor: 'border-violet-200',
    population: '~15% of people',
  },
  dolphin: {
    id: 'dolphin',
    name: 'Dolphin',
    emoji: '🐬',
    tagline: 'The Light Sleeper',
    description: 'You\'re always slightly alert, even in sleep. Dolphins are light sleepers with irregular rhythms — your energy can spike unpredictably, and you\'re often most productive in focused bursts throughout the day.',
    sleepWindow: '11:30 PM – 6:30 AM',
    peakFocus: '10:00 AM – 12:00 PM',
    bestFor: 'Short focused sprints, problem-solving, analytical work',
    color: 'text-sky-600',
    bgColor: 'bg-sky-50',
    borderColor: 'border-sky-200',
    population: '~10% of people',
  },
}

export const chronotypeOrder: ChronotypeId[] = ['lion', 'bear', 'wolf', 'dolphin']

export function getChronotype(id: ChronotypeId): ChronotypeInfo {
  return chronotypes[id]
}
