import type { ChronotypeId } from './chronotypes'

export interface PairingInfo {
  name: string
  bestWindow: string
  gapWindow: string
  worthKnowing: string
  overlapScore: number // 1-5, how naturally aligned the pair is
}

function pairingKey(a: ChronotypeId, b: ChronotypeId): string {
  return [a, b].sort().join('_')
}

const pairingsMap: Record<string, PairingInfo> = {
  wolf_wolf: {
    name: 'The Late Night Society',
    bestWindow: '6:00 PM – 11:00 PM',
    gapWindow: 'Mornings are nobody\'s problem',
    worthKnowing: 'You both peak late — your evenings are electric, but you\'ll need external structure for mornings.',
    overlapScore: 5,
  },
  bear_wolf: {
    name: 'The Night Owl and the Middler',
    bestWindow: '4:00 PM – 8:00 PM',
    gapWindow: 'Mornings (Bear is up; Wolf is not)',
    worthKnowing: 'The Bear can ease into the day while the Wolf ramps up. Your overlap lives in late afternoon.',
    overlapScore: 3,
  },
  lion_wolf: {
    name: 'The Midnight Sun Pair',
    bestWindow: '12:00 PM – 3:00 PM',
    gapWindow: 'Early morning and late evening — you\'re on opposite schedules',
    worthKnowing: 'This is the hardest pairing for shared time. Protect your midday overlap like it\'s sacred.',
    overlapScore: 1,
  },
  dolphin_wolf: {
    name: 'Two Restless Ones',
    bestWindow: '5:00 PM – 9:00 PM',
    gapWindow: 'Mornings are rough for both, but for different reasons',
    worthKnowing: 'You both resist conventional schedules. The evening is your playground — lean into it.',
    overlapScore: 3,
  },
  bear_bear: {
    name: 'The Solid Eight',
    bestWindow: '9:00 AM – 9:00 PM',
    gapWindow: 'Minimal — you\'re naturally in sync',
    worthKnowing: 'You\'re the most common pairing and the most naturally aligned. Don\'t take the harmony for granted.',
    overlapScore: 5,
  },
  bear_lion: {
    name: 'The Early Start and the Steady State',
    bestWindow: '8:00 AM – 6:00 PM',
    gapWindow: 'Early morning (Lion is up; Bear is warming up)',
    worthKnowing: 'The Lion gets a head start each day. By mid-morning you\'re in perfect sync.',
    overlapScore: 4,
  },
  bear_dolphin: {
    name: 'The Easygoing and the Alert',
    bestWindow: '10:00 AM – 7:00 PM',
    gapWindow: 'Bedtime (Dolphin takes longer to wind down)',
    worthKnowing: 'The Bear\'s steady rhythm can be grounding for the Dolphin\'s variable energy.',
    overlapScore: 3,
  },
  lion_lion: {
    name: 'The Dawn Chorus',
    bestWindow: '6:00 AM – 2:00 PM',
    gapWindow: 'Evenings — you\'re both fading fast',
    worthKnowing: 'Your mornings are powerful together. Plan dates before sunset — you\'ll both be asleep by 10.',
    overlapScore: 5,
  },
  dolphin_lion: {
    name: 'The Early Riser and the Light Sleeper',
    bestWindow: '7:00 AM – 1:00 PM',
    gapWindow: 'Bedtime misalignment — Lion crashes, Dolphin\'s mind races',
    worthKnowing: 'The Lion\'s predictable rhythm helps stabilize the Dolphin. Mornings together are your anchor.',
    overlapScore: 3,
  },
  dolphin_dolphin: {
    name: 'The Midnight Overthinkers',
    bestWindow: '10:00 AM – 8:00 PM',
    gapWindow: 'Late night — two active minds, no off switch',
    worthKnowing: 'You understand each other\'s restlessness. Build a shared wind-down ritual — you both need one.',
    overlapScore: 4,
  },
}

export function getPairing(a: ChronotypeId, b: ChronotypeId): PairingInfo {
  const key = pairingKey(a, b)
  return pairingsMap[key]
}

export function getAllPairings(): { key: string; a: ChronotypeId; b: ChronotypeId; info: PairingInfo }[] {
  return Object.entries(pairingsMap).map(([key, info]) => {
    const [a, b] = key.split('_') as [ChronotypeId, ChronotypeId]
    return { key, a, b, info }
  })
}
