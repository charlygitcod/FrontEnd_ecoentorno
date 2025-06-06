<template>
    <div class="admin-section">
      <h2>Vista del Coordinador</h2>
      <div class="content-container">
        <h3>Lista de Registros</h3>
  
        <!-- Filtrado por Turno -->
        <div class="form-group">
          <label for="filtroTurno">Filtrar por Turno:</label>
          <select v-model="filtroTurno" class="form-input">
            <option value="todos">Todos</option>
            <option value="mañana">Mañana</option>
            <option value="tarde">Tarde</option>
            <option value="noche">Noche</option>
          </select>
        </div>
  
        <!-- Filtrado por Mes -->
        <div class="form-group">
          <label for="filtroMes">Filtrar por Mes:</label>
          <input type="month" v-model="filtroMes" class="form-input">
        </div>
  
        <!-- Filtrado por Documento -->
        <div class="form-group">
          <label for="filtroDocumento">Filtrar por Documento del Operario:</label>
          <input type="number" v-model="filtroDocumento" class="form-input" placeholder="Ingrese documento">
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
  
        <div id="download-btn">
          <button @click="descargarExcel" class="form-submit-button">Descargar Excel</button>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, onMounted } from 'vue';
  import axios from 'axios';
  import Swal from 'sweetalert2';
  import * as XLSX from 'xlsx';
  
  const registros = ref([]);
  const filtroTurno = ref('todos');
  const filtroMes = ref('');
  const filtroDocumento = ref('');
  const documentoUsuario = ref(localStorage.getItem('nombre_usuario') || '');
  
  // Computed para filtrar los registros
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
  
    if (filtroDocumento.value) {
      filtrados = filtrados.filter(registro =>
        registro.empleado_documento.toString().includes(filtroDocumento.value.toString())
      );
    }
  
    return filtrados;
  });
  
  // Función para obtener registros
  const obtenerRegistros = async () => {
    try {
      const response = await axios.get('https://backendecoentorno-production.up.railway.app/consultarpesos');
      registros.value = response.data;
    } catch (error) {
      Swal.fire({ icon: 'error', title: 'Error', text: 'Error al obtener los registros.' });
    }
  };
  
  // Función para mostrar bienvenida
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
  
  // Función para descargar datos en Excel
  const descargarExcel = () => {
    const worksheet = XLSX.utils.json_to_sheet(registrosFiltrados.value);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Registros');
    XLSX.writeFile(workbook, 'registros.xlsx');
  };
  
  // Ejecutar al montar el componente
  onMounted(() => {
    mostrarBienvenida();
    obtenerRegistros();
  });
  </script>
  
  
  <style scoped>
  .admin-section {
    padding: 20px;
  }
  
  .content-container {
    display: flex;
    flex-direction: column;
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
  
  #download-btn {
    max-width: 100%;
    margin-top: 20px;
    width: 100%;
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
  </style>
  