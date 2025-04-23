<template>
  <div class="admin-section">
  <h3>Gestión de Credenciales</h3>
  <div class="content-container">

    <!-- 📱 Móvil: tarjeta -->
    <div v-if="isMobile && credencialActual" class="credencial-card">
      <p><strong>Empleado Documento:</strong> {{ credencialActual.empleado_documento }}</p>
      <p><strong>Contraseña:</strong> {{ credencialActual.password }}</p>
      <div class="actions-container">
        <button @click="editarCredencial(credencialActual)" class="edit-btn">Editar</button>
        <button @click="eliminarCredencial(credencialActual.empleado_documento)" class="delete-btn">Eliminar</button>
      </div>
      <div v-if="credenciales.length > 1" class="navigation-arrows">
        <button @click="anteriorCredencial" :disabled="currentIndex === 0">⬅️</button>
        <span>{{ currentIndex + 1 }} / {{ credenciales.length }}</span>
        <button @click="siguienteCredencial" :disabled="currentIndex === credenciales.length - 1">➡️</button>
      </div>
    </div>

    <!-- 💻 Escritorio: tabla -->
    <div v-else class="table-container-CREDENCIAL">
      <table class="table-credenciales">
        <thead>
          <tr>
            <th>Empleado Documento</th>
            <th>Contraseña</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="credencial in credenciales" :key="credencial.empleado_documento">
            <td>{{ credencial.empleado_documento }}</td>
            <td class="password-cell">{{ credencial.password }}</td>
            <td>
              <div class="actions-container">
                <button @click="editarCredencial(credencial)" class="edit-btn">Editar</button>
                <button @click="eliminarCredencial(credencial.empleado_documento)" class="delete-btn">Eliminar</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 🧾 Formulario -->
    <div class="form-wrapper-CREDENCIALES">
      <h1>{{ editModeCredencial ? 'Editar Credencial' : 'Agregar Credencial' }}</h1>
      <form @submit.prevent="guardarCredencial">
        <div class="form-group">
          <label for="empleado_documento">Empleado Documento</label>
          <input type="text" id="empleado_documento" v-model="empleado_documento" placeholder="Documento" required class="form-input" :disabled="editModeCredencial" />
        </div>
        <div class="form-group">
          <label for="password">Contraseña</label>
          <input type="password" id="password" v-model="password" placeholder="Contraseña" required class="form-input" />
        </div>
        <div class="cont-btn">
          <button type="submit" class="form-submit-button">{{ editModeCredencial ? 'Actualizar' : 'Agregar' }}</button>
          <button type="button" @click="resetCredencial" class="form-toggle-button">{{ editModeCredencial ? 'Cancelar Edición' : 'Limpiar Formulario' }}</button>
        </div>
        <p v-if="errorMessage" class="form-error">{{ errorMessage }}</p>
        <p v-if="successMessage" class="form-success">{{ successMessage }}</p>
      </form>
    </div>

  </div>
</div>
</template>


<script setup>
import { ref, onMounted, watch } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';

const empleado_documento = ref('');
const password = ref('');
const credenciales = ref([]);
const editModeCredencial = ref(false);
const successMessage = ref('');
const errorMessage = ref('');
const currentIndex = ref(0);
const isMobile = ref(window.innerWidth <= 420);
const credencialActual = ref(null);

const guardarCredencial = async () => {
  const credencial = {
    empleado_documento: empleado_documento.value,
    password: password.value,
  };

  try {
    if (editModeCredencial.value) {
      await axios.put(`https://backendecoentorno-production.up.railway.app/modificarcredencial/${empleado_documento.value}`, credencial);
      await Swal.fire('Éxito', 'Credencial actualizada exitosamente', 'success');
    } else {
      await axios.post('https://backendecoentorno-production.up.railway.app/insertarcredencial', credencial);
      await Swal.fire('Éxito', 'Credencial agregada exitosamente', 'success');
    }
    await obtenerCredenciales();
    resetCredencial();
  } catch (error) {
    await Swal.fire('Error', error.response?.data?.detail || 'Error al guardar la credencial', 'error');
  }
};

const obtenerCredenciales = async () => {
  try {
    const response = await axios.get('https://backendecoentorno-production.up.railway.app/consultarcredenciales');
    credenciales.value = response.data;
    actualizarVista();
  } catch (error) {
    await Swal.fire('Error', 'Error al obtener la lista de credenciales', 'error');
  }
};

const eliminarCredencial = async (documento) => {
  const result = await Swal.fire({
    title: '¿Estás seguro?',
    text: '¡No podrás recuperar esta credencial!',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
  });

  if (result.isConfirmed) {
    try {
      await axios.delete(`https://backendecoentorno-production.up.railway.app/eliminarcredencial/${documento}`);
      await Swal.fire('Eliminado', 'Credencial eliminada exitosamente', 'success');
      await obtenerCredenciales();
    } catch (error) {
      await Swal.fire('Error', 'Error al eliminar la credencial', 'error');
    }
  }
};

const editarCredencial = (credencial) => {
  empleado_documento.value = credencial.empleado_documento;
  password.value = credencial.password;
  editModeCredencial.value = true;
};

const resetCredencial = () => {
  empleado_documento.value = '';
  password.value = '';
  editModeCredencial.value = false;
  successMessage.value = '';
  errorMessage.value = '';
};

const siguienteCredencial = () => {
  if (currentIndex.value < credenciales.value.length - 1) {
    currentIndex.value++;
  }
};

const anteriorCredencial = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--;
  }
};

const actualizarVista = () => {
  if (isMobile.value) {
    credencialActual.value = credenciales.value[currentIndex.value] || null;
  } else {
    credencialActual.value = null;
  }
};

const handleResize = () => {
  isMobile.value = window.innerWidth <= 420;
  actualizarVista();
};

onMounted(() => {
  obtenerCredenciales();
  window.addEventListener('resize', handleResize);
});

watch([isMobile, currentIndex, credenciales], actualizarVista);
</script>
<style scoped>
.admin-section{
  text-align: center;
  width: 100%;
}
.table-container-CREDENCIAL {
  width: 100%;
  margin-top: 20px;
}

.table-credenciales {
  width: 100%;
  background-color: antiquewhite;
  border-collapse: collapse;
}

th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

th {
  background-color: #f2f2f2;
}

.actions-container {
  display: flex;
  gap: 10px;
}

.edit-btn {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

.delete-btn {
  background-color: #f44336;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

.form-wrapper-CREDENCIALES {
  background-color: #f9f9f9;
  width: 100%;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  text-align: center;
  margin-top: 20px;
}

.form-group {
  margin-bottom: 15px;
}

.form-input {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.cont-btn{
  display: flex;
}

.form-submit-button, .form-toggle-button {
  background-color: #4CAF50;
  color: white;
  width: 50%;
  border: none;
  padding: 10px;
  cursor: pointer;
  border-radius: 4px;
}

.form-toggle-button {
  background-color: #f44336;
  margin-left: 10px;
}

.form-error, .form-success {
  color: red;
}
@media (max-width: 420px) {
  .table-container-CREDENCIAL {
    display: none;
  }

  .credencial-card {
    background-color: antiquewhite;
    padding: 20px;
    margin: 10px auto;
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
    width: 90%;
    text-align: left;
  }

  .navigation-arrows {
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .navigation-arrows button {
    background-color: #4CAF50;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 5px;
    cursor: pointer;
  }

  .navigation-arrows span {
    font-weight: bold;
  }
  .credencial-card p {
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  }

}
td.password-cell {
  max-width: 150px; /* o el ancho que se ajuste a tu diseño */
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
