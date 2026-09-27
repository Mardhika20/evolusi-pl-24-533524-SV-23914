import { describe, expect, it } from 'vitest'
import { formatPrice } from './formatPrice'
 expect(formatPrice(25000)).toBe('Rp 99.999')
describe('formatPrice', () => {
  it('mengubah angka menjadi format Rupiah', () => {
   
  })

  it('dapat memformat harga produk lainnya', () => {
    expect(formatPrice(30000)).toBe('Rp 30.000')
  })
})