<template>
   <header>
    <h1>Registro de EPPS</h1>
  </header>
  <div class="admin-section">
    
    <div class="content-container">
      <div id="formulario" class="form-wrapper">
        <form @submit.prevent="agregarEntrega">
          <div class="form-group">
            <label for="documento">Documento del Empleado:</label>
            <input type="number" v-model="nuevaEntrega.empleado_documento" required class="form-input" />
          </div>
          <div class="form-group">
            <label for="nombre_ope">Nombre del Empleado:</label>
            <input type="text" v-model="nuevaEntrega.nombre_ope" required class="form-input" />
          </div>
          <div class="form-group">
            <label for="nombre_epp">Nombre del EPP:</label>
            <input type="text" v-model="nuevaEntrega.nombre_epp" required class="form-input" />
          </div>
          <div class="form-group">
            <label for="cantidad">Cantidad:</label>
            <input type="number" v-model="nuevaEntrega.cantidad" required class="form-input" />
          </div>
          <div class="cont-btn">
            <button type="submit" class="form-submit-button">Registrar Entrega</button>
          </div>
        </form>
      </div>

      <h3>Lista de Entregas de EPP</h3>
      <div class="form-group">
        <label for="busqueda">Buscar:</label>
        <input type="text" v-model="terminoBusqueda" placeholder="Documento, Nombre o Apellido" class="form-input" />
      </div>

      <div id="tabla" class="table-container">
        <table>
          <thead>
            <tr>
              <th>Empleado Documento</th>
              <th>Nombre Operación</th>
              <th>Nombre EPP</th>
              <th>Cantidad</th>
              <th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="entrega in entregasFiltradas" :key="entrega.id_entrega">
              <td>{{ entrega.empleado_documento }}</td>
              <td>{{ entrega.nombre_ope }}</td>
              <td>{{ entrega.nombre_epp }}</td>
              <td>{{ entrega.cantidad }}</td>
              <td>{{ entrega.fecha }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';

const nuevaEntrega = ref({
  empleado_documento: '',
  nombre_ope: '',
  nombre_epp: '',
  cantidad: ''
});

const entregas = ref([]);
const terminoBusqueda = ref('');
const documentoUsuario = ref(localStorage.getItem('nombre_usuario') || '');

// Función para obtener la fecha actual
const obtenerFechaActual = () => {
  const fecha = new Date();
  return fecha.toISOString().split('T')[0];
};

// Función para agregar una entrega
const agregarEntrega = async () => {
  try {
    const entregaConFecha = { ...nuevaEntrega.value, fecha: obtenerFechaActual() };
    const response = await axios.post('https://backendecoentorno-production.up.railway.app/insertarepp', entregaConFecha);
    entregas.value.push(response.data);

    Swal.fire({
      icon: 'success',
      title: 'Registro agregado con éxito',
      text: `Documento del empleado: ${nuevaEntrega.value.empleado_documento}`
    });

    nuevaEntrega.value = { empleado_documento: '', nombre_ope: '', nombre_epp: '', cantidad: '' };
  } catch (error) {
    Swal.fire({
      icon: 'error',
      title: 'Error al registrar la entrega',
      text: 'Hubo un problema al intentar registrar la entrega.'
    });
  }
};

// Función para obtener las entregas de EPP
const obtenerEntregas = async () => {
  try {
    const response = await axios.get('https://backendecoentorno-production.up.railway.app/consultarepp');
    entregas.value = response.data;
  } catch (error) {
    Swal.fire({
      icon: 'error',
      title: 'Error al cargar las entregas',
      text: 'No se pudieron cargar las entregas desde el servidor.'
    });
  }
};

// Función para mostrar la bienvenida con nombre, apellido y documento
const mostrarBienvenida = async () => {
  try {
    const documentoGuardado = localStorage.getItem('nombre_usuario');
    if (!documentoGuardado) {
      Swal.fire({ icon: 'error', title: 'Error', text: 'Usuario no identificado.' });
      return;
    }
    
    const response = await axios.get('https://backendecoentorno-production.up.railway.app/consultarusuarios');
    const usuario = response.data.find(user => user.documento === parseInt(documentoGuardado));
    
    if (usuario) {
      Swal.fire({
        icon: 'success',
        title: `Bienvenido, ${usuario.nombre} ${usuario.apellido}`,
        text: `Documento: ${usuario.documento}`
      });
    }
  } catch (error) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo obtener la información del usuario.' });
  }
};

// Filtrar las entregas por documento, nombre o apellido
const entregasFiltradas = computed(() => {
  const termino = terminoBusqueda.value.toLowerCase().trim();
  return entregas.value.filter(entrega =>
    entrega.empleado_documento.toString().includes(termino) ||
    entrega.nombre_ope.toLowerCase().includes(termino)
  );
});

// Ejecutar la bienvenida y cargar entregas al montar el componente
onMounted(() => {
  mostrarBienvenida();
  obtenerEntregas();
});
</script>

<style scoped>

header{
  position: fixed;
  top: 0;
  width: 100%;
  background: linear-gradient(to right,#9acff3, #e18dfa );
  
  
}
h1{
  text-align: center;
}
.admin-section {
  padding: 20px;
}

.content-container {
 
  text-align: center;
  
}

.form-wrapper {
  margin-bottom: 20px;
  margin-left: auto;
  margin-right: auto;
}

.form-group {
  text-align: left;
  margin-bottom: 15px;
}

.form-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-top: 5px;
}

.cont-btn {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.form-submit-button {
  background-color: #4CAF50;
  color: white;
  width: 100%;
  border: none;
  padding: 10px;
  cursor: pointer;
  border-radius: 4px;
}

.table-container {
  width: 100%;
  margin-top: 20px;
}

table {
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

@media screen and (max-width:600px) {
#formulario{
  max-width: 100%;
  background-color: rgb(198, 197, 197);
}
#tabla{
  max-width: 100%;
}
  
}
</style>
