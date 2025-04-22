<template>
  <div class="admin-section">
    <h2>Registrar Pesos</h2>
    <div class="content-container">
      <div class="form-wrapper">
        <form @submit.prevent="agregarRegistro">
          <div class="form-group">
            <label for="tipo">Tipo de Registro:</label>
            <select v-model="nuevoRegistro.tipo" required class="form-input">
              <option value="patologico">Patológico</option>
              <option value="biosanitario">Biosanitario</option>
            </select>
          </div>
          <div class="form-group">
            <label for="peso">Peso (kg):</label>
            <input type="number" step="0.01" v-model="nuevoRegistro.peso" required class="form-input" />
          </div>
          <div class="form-group">
            <label for="turno">Turno:</label>
            <select v-model="nuevoRegistro.turno" required class="form-input">
              <option value="mañana">Mañana</option>
              <option value="tarde">Tarde</option>
              <option value="noche">Noche</option>
            </select>
          </div>
          <div class="cont-btn">
            <button type="submit" class="form-submit-button">Registrar Peso</button>
          </div>
        </form>
      </div>

      <h3>Lista de Registros</h3>
      <div class="form-group">
        <label for="filtroTurno">Filtrar por Turno:</label>
        <select v-model="filtroTurno" class="form-input">
          <option value="todos">Todos</option>
          <option value="mañana">Mañana</option>
          <option value="tarde">Tarde</option>
          <option value="noche">Noche</option>
        </select>
      </div>
      <div class="form-group">
        <label for="filtroMes">Filtrar por Mes:</label>
        <input type="month" v-model="filtroMes" class="form-input" />
      </div>

      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>Empleado Documento</th>
              <th>Peso (kg)</th>
              <th>Tipo</th>
              <th>Turno</th>
              <th>Fecha</th>
              <th>Hora</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="registro in registrosFiltrados" :key="registro.id_registro">
              <td>{{ registro.empleado_documento }}</td>
              <td>{{ registro.peso }} kg</td>
              <td>{{ registro.tipo }}</td>
              <td>{{ registro.turno }}</td>
              <td>{{ registro.fecha }}</td>
              <td>{{ registro.hora }}</td>
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

const nuevoRegistro = ref({
  tipo: 'patologico',
  peso: '',
  turno: 'mañana',
});

const registros = ref([]);
const filtroTurno = ref('todos');
const filtroMes = ref('');
const documentoUsuario = ref(localStorage.getItem('nombre_usuario') || '');

const registrosFiltrados = computed(() => {
  let filtrados = registros.value;
  if (filtroTurno.value !== 'todos') {
    filtrados = filtrados.filter(registro => registro.turno === filtroTurno.value);
  }
  if (filtroMes.value) {
    const [añoSeleccionado, mesSeleccionado] = filtroMes.value.split('-');
    filtrados = filtrados.filter(registro => {
      const [añoRegistro, mesRegistro] = registro.fecha.split('-');
      return añoRegistro === añoSeleccionado && mesRegistro === mesSeleccionado;
    });
  }
  return filtrados;
});

const agregarRegistro = async () => {
  try {
    const { fecha, hora } = obtenerFechaHoraActual();
    const registroConFecha = {
      ...nuevoRegistro.value,
      empleado_documento: documentoUsuario.value,
      fecha,
      hora,
    };
    const response = await axios.post('http://localhost:8000/insertarpesos', registroConFecha);
    Swal.fire({
      icon: 'success',
      title: 'Registro agregado con éxito',
      text: `Documento: ${documentoUsuario.value}`,
    });
    registros.value.push(response.data);
    nuevoRegistro.value = { tipo: 'patologico', peso: '', turno: 'mañana' };
  } catch (error) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'Ocurrió un error al agregar el registro.' });
  }
};

onMounted(async () => {
  const documentoGuardado = localStorage.getItem('nombre_usuario');
  if (!documentoGuardado) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'Usuario no identificado.' });
  } else {
    documentoUsuario.value = documentoGuardado;
    await obtenerUsuario(documentoGuardado);
    obtenerRegistros(documentoGuardado);
  }
});

const obtenerUsuario = async (documento) => {
  try {
    const response = await axios.get('http://localhost:8000/consultarusuarios');
    const usuario = response.data.find(user => user.documento === parseInt(documento));
    if (usuario) {
      Swal.fire({
        icon: 'success',
        title: `Bienvenido, ${usuario.nombre} ${usuario.apellido}`,
        text: `Documento: ${usuario.documento}`,
      });
    }
  } catch (error) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo obtener el usuario.' });
  }
};

const obtenerRegistros = async (documento) => {
  try {
    const response = await axios.get('http://localhost:8000/consultarpesos');
    registros.value = response.data.filter(
      registro => registro.empleado_documento === parseInt(documento)
    );
  } catch (error) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'Error al obtener los registros.' });
  }
};

const obtenerFechaHoraActual = () => {
  const fecha = new Date();
  return {
    fecha: fecha.toISOString().split('T')[0],
    hora: fecha.toTimeString().split(' ')[0].slice(0, 5),
  };
};
</script>

<style scoped>
.admin-section {
  padding: 20px;
}

.content-container {
  display: flex;
  flex-direction: column;
}

.form-wrapper {
  margin-bottom: 20px;
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

.download-btn {
  margin-top: 20px;
}
</style>
