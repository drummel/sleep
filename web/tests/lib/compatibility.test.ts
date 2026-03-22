import { describe, it, expect } from 'vitest'
import { getPairing, getAllPairings } from '../../app/lib/compatibility'
import type { ChronotypeId } from '../../app/lib/chronotypes'

describe('getPairing', () => {
  it('returns wolf+wolf pairing', () => {
    const info = getPairing('wolf', 'wolf')
    expect(info.name).toBe('The Late Night Society')
    expect(info.overlapScore).toBe(5)
  })

  it('returns bear+wolf pairing', () => {
    const info = getPairing('bear', 'wolf')
    expect(info.name).toBe('The Night Owl and the Middler')
  })

  it('returns lion+wolf pairing', () => {
    const info = getPairing('lion', 'wolf')
    expect(info.name).toBe('The Midnight Sun Pair')
    expect(info.overlapScore).toBe(1)
  })

  it('returns dolphin+wolf pairing', () => {
    const info = getPairing('dolphin', 'wolf')
    expect(info.name).toBe('Two Restless Ones')
  })

  it('returns bear+bear pairing', () => {
    const info = getPairing('bear', 'bear')
    expect(info.name).toBe('The Solid Eight')
    expect(info.overlapScore).toBe(5)
  })

  it('returns bear+lion pairing', () => {
    const info = getPairing('bear', 'lion')
    expect(info.name).toBe('The Early Start and the Steady State')
  })

  it('returns bear+dolphin pairing', () => {
    const info = getPairing('bear', 'dolphin')
    expect(info.name).toBe('The Easygoing and the Alert')
  })

  it('returns lion+lion pairing', () => {
    const info = getPairing('lion', 'lion')
    expect(info.name).toBe('The Dawn Chorus')
  })

  it('returns dolphin+lion pairing', () => {
    const info = getPairing('dolphin', 'lion')
    expect(info.name).toBe('The Early Riser and the Light Sleeper')
  })

  it('returns dolphin+dolphin pairing', () => {
    const info = getPairing('dolphin', 'dolphin')
    expect(info.name).toBe('The Midnight Overthinkers')
  })

  it('is symmetric - wolf+bear equals bear+wolf', () => {
    const a = getPairing('wolf', 'bear')
    const b = getPairing('bear', 'wolf')
    expect(a.name).toBe(b.name)
    expect(a.bestWindow).toBe(b.bestWindow)
  })

  it('all pairings have required fields', () => {
    const types: ChronotypeId[] = ['lion', 'bear', 'wolf', 'dolphin']
    for (const a of types) {
      for (const b of types) {
        const info = getPairing(a, b)
        expect(info.name).toBeTruthy()
        expect(info.bestWindow).toBeTruthy()
        expect(info.gapWindow).toBeTruthy()
        expect(info.worthKnowing).toBeTruthy()
        expect(info.overlapScore).toBeGreaterThanOrEqual(1)
        expect(info.overlapScore).toBeLessThanOrEqual(5)
      }
    }
  })
})

describe('getAllPairings', () => {
  it('returns 10 unique pairings', () => {
    expect(getAllPairings()).toHaveLength(10)
  })

  it('each pairing has required structure', () => {
    for (const p of getAllPairings()) {
      expect(p.key).toBeTruthy()
      expect(p.a).toBeTruthy()
      expect(p.b).toBeTruthy()
      expect(p.info.name).toBeTruthy()
    }
  })

  it('all pairing names are unique', () => {
    const names = getAllPairings().map(p => p.info.name)
    expect(new Set(names).size).toBe(10)
  })
})
