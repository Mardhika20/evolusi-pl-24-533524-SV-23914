<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <header>
    <h1>Product App</h1>

    <nav>
      <RouterLink to="/">Home</RouterLink>
      |
      <RouterLink to="/products">Products</RouterLink>
    </nav>
  </header>

  <RouterView />
</template>