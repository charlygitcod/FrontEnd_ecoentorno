<template>
  <div class="form-container">
    <div id="conraper" class="form-wrapper">
      <!-- Logo de la aplicación -->
      <img src="../components/icons/favicon-ecoentornos-1920w.png" alt="Logo de la App" class="logo" />
      
      <!-- Nombre de la aplicación -->
      <h1 class="app-name">SAFE-CONTROL</h1>

      <h2>Iniciar sesión</h2>
      <form @submit.prevent="loginUsuario">
        <div class="form-group">
          <label for="nombreUsuario">Usuario:</label>
          <input type="number" id="nombreUsuario" v-model="nombreUsuario" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="password">Contraseña:</label>
          <input type="password" id="password" v-model="password" required class="form-input" />
        </div>
        <button type="submit" class="form-submit-button">Iniciar sesión</button>
        <p v-if="menError" class="form-error">{{ menError }}</p>
        <p v-if="menExito" class="form-success">{{ menExito }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import Swal from 'sweetalert2';
import { ref } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const nombreUsuario = ref('');
const password = ref('');
const menError = ref('');
const menExito = ref('');

const loginUsuario = async () => {
  try {
    // Enviar solicitud POST al backend para autenticar al usuario
    const response = await axios.post('https://backendecoentorno-production.up.railway.app/login', {
      nombre_usuario: nombreUsuario.value,
      password: password.value,
    });

    const { rol, nombre_usuario } = response.data;

    // Guardar el nombre de usuario en localStorage
    localStorage.setItem('nombre_usuario', nombreUsuario.value);
    console.log('Usuario guardado en localStorage: ', localStorage.getItem('nombre_usuario'));

    // Redirigir según el rol del usuario
    if (rol === 'administrador') {
      router.push('/ModuloAdmin');
    } else if (rol === 'operario') {
      router.push('/pesos');
    } else if (rol === 'usuario_epp') {
      router.push('/epps');
    } else if (rol === 'coordinador') {
      router.push('/modcoor');
    } else {
      throw new Error('Rol no válido');
    }

    // Mostrar mensaje de éxito
    menExito.value = 'Inicio de sesión exitoso';
    Swal.fire({
      icon: 'success',
      title: 'Inicio de Sesión',
      text: 'Inicio de sesión exitoso',
    });

    // Limpiar mensaje de éxito después de 3 segundos
    setTimeout(() => {
      menExito.value = '';
    }, 3000);
  } catch (error) {
    console.error('Error al iniciar sesión', error);
    menError.value = 'Error al iniciar sesión. Verifique sus credenciales.';
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Error al iniciar sesión',
    });

    // Limpiar mensaje de error después de 3 segundos
    setTimeout(() => {
      menError.value = '';
    }, 3000);
  }
};
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: linear-gradient(to right, #e18dfa, #9acff3);
  font-family: Arial, sans-serif;
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  
  justify-content: center;
  align-items: center;
}

.form-container {
 
  width: 100%;
  justify-content: center;
  padding: 20px;
  align-items: center;
}

#conraper{
  text-align: center;
  width: 25%;
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
}

.logo {
  width: 80px;
  height: auto;
  margin-bottom: 15px;
}

.app-name {
  color: #333;
  margin: 0 0 20px 0;
  font-size: 1.5rem;
}

h2 {
  margin: 0 0 20px 0;
  color: #444;
  font-size: 1.3rem;
}

.form-group {
  margin-bottom: 20px;
  text-align: left;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #555;
  font-weight: bold;
}

.form-input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
}

.form-submit-button {
  background-color: #007bff;
  color: white;
  padding: 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  width: 100%;
  font-size: 1rem;
  font-weight: bold;
  transition: background-color 0.3s;
}

.form-submit-button:hover {
  background-color: #0056b3;
}

.form-error {
  color: #dc3545;
  margin: 15px 0 0 0;
  font-size: 0.9rem;
}

.form-success {
  color: #28a745;
  margin: 15px 0 0 0;
  font-size: 0.9rem;
}

@media screen and (max-width: 600px) {
  #conraper{
    width: 90%;
    
  }
}
</style>

