<script setup>
import { onMounted, ref } from 'vue'
import { formatPrice } from '../utils/formatPrice'

const products = ref([])
const loading = ref(true)
const error = ref('')

const API_URL = import.meta.env.VITE_API_URL

const fetchProducts = async () => {
  try {
    const response = await fetch(`${API_URL}/api/products`)

    if (!response.ok) {
      throw new Error('Gagal mengambil data produk')
    }

    products.value = await response.json()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchProducts()
})
</script>

<template>
  <main>
    <h1>Daftar Produk</h1>

    <p v-if="loading">
      Memuat data produk...
    </p>

    <p v-else-if="error">
      {{ error }}
    </p>

    <p v-else-if="products.length === 0">
      Belum ada data produk.
    </p>

    <ul v-else>
      <li v-for="product in products" :key="product.id">
        {{ product.name }} - {{ formatPrice(product.price) }}
      </li>
    </ul>
  </main>
</template>