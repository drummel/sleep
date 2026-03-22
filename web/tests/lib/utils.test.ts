import { describe, it, expect } from 'vitest'
import { cn } from '../../app/lib/utils'

describe('cn', () => {
  it('merges class names', () => {
    expect(cn('foo', 'bar')).toBe('foo bar')
  })

  it('handles conditional classes', () => {
    expect(cn('base', false && 'hidden', 'visible')).toBe('base visible')
  })

  it('merges tailwind classes', () => {
    const result = cn('px-4 py-2', 'px-6')
    expect(result).toContain('px-6')
    expect(result).not.toContain('px-4')
  })

  it('handles undefined and null', () => {
    expect(cn('base', undefined, null, 'end')).toBe('base end')
  })

  it('handles empty string', () => {
    expect(cn('', 'foo')).toBe('foo')
  })

  it('handles arrays', () => {
    expect(cn(['foo', 'bar'])).toBe('foo bar')
  })
})
