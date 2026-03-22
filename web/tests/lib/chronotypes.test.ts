import { describe, it, expect } from 'vitest'
import { chronotypes, chronotypeOrder, getChronotype, type ChronotypeId } from '../../app/lib/chronotypes'

describe('chronotypes data', () => {
  it('has all 4 chronotypes', () => {
    expect(Object.keys(chronotypes)).toHaveLength(4)
    expect(chronotypes.lion).toBeDefined()
    expect(chronotypes.bear).toBeDefined()
    expect(chronotypes.wolf).toBeDefined()
    expect(chronotypes.dolphin).toBeDefined()
  })

  it('each chronotype has required fields', () => {
    for (const ct of Object.values(chronotypes)) {
      expect(ct.id).toBeTruthy()
      expect(ct.name).toBeTruthy()
      expect(ct.emoji).toBeTruthy()
      expect(ct.tagline).toBeTruthy()
      expect(ct.description).toBeTruthy()
      expect(ct.sleepWindow).toBeTruthy()
      expect(ct.peakFocus).toBeTruthy()
      expect(ct.bestFor).toBeTruthy()
      expect(ct.color).toBeTruthy()
      expect(ct.bgColor).toBeTruthy()
      expect(ct.borderColor).toBeTruthy()
      expect(ct.population).toBeTruthy()
    }
  })

  it('lion has correct data', () => {
    expect(chronotypes.lion.name).toBe('Lion')
    expect(chronotypes.lion.emoji).toBe('🦁')
    expect(chronotypes.lion.tagline).toBe('The Early Riser')
  })

  it('bear has correct data', () => {
    expect(chronotypes.bear.name).toBe('Bear')
    expect(chronotypes.bear.emoji).toBe('🐻')
    expect(chronotypes.bear.tagline).toBe('The Solar Tracker')
  })

  it('wolf has correct data', () => {
    expect(chronotypes.wolf.name).toBe('Wolf')
    expect(chronotypes.wolf.emoji).toBe('🐺')
  })

  it('dolphin has correct data', () => {
    expect(chronotypes.dolphin.name).toBe('Dolphin')
    expect(chronotypes.dolphin.emoji).toBe('🐬')
  })
})

describe('chronotypeOrder', () => {
  it('has 4 entries', () => {
    expect(chronotypeOrder).toHaveLength(4)
  })

  it('contains all types in order', () => {
    expect(chronotypeOrder[0]).toBe('lion')
    expect(chronotypeOrder[1]).toBe('bear')
    expect(chronotypeOrder[2]).toBe('wolf')
    expect(chronotypeOrder[3]).toBe('dolphin')
  })
})

describe('getChronotype', () => {
  it('returns correct info for each type', () => {
    const types: ChronotypeId[] = ['lion', 'bear', 'wolf', 'dolphin']
    for (const id of types) {
      const info = getChronotype(id)
      expect(info.id).toBe(id)
      expect(info).toBe(chronotypes[id])
    }
  })

  it('returns full object with all fields', () => {
    const lion = getChronotype('lion')
    expect(lion.id).toBe('lion')
    expect(lion.emoji).toBe('🦁')
    expect(lion.sleepWindow).toContain('PM')
    expect(lion.peakFocus).toContain('AM')
  })
})
