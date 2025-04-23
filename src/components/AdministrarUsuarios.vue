<template>
  <div class="search-container">
    <input 
      type="text" 
      v-model="searchQuery" 
      placeholder="Buscar por cédula, nombre o apellido" 
      class="search-input" 
    />
  </div>

  <div class="form-container">
    <div class="table-container">
      <h2 class="Lusu">Lista de Usuarios</h2>
      <div v-if="isMobile && usuarioActual" class="usuario-card">
        <p><strong>Documento:</strong> {{ usuarioActual.documento }}</p>
        <p><strong>Nombre:</strong> {{ usuarioActual.nombre }}</p>
        <p><strong>Segundo Nombre:</strong> {{ usuarioActual.segundo_nombre }}</p>
        <p><strong>Apellido:</strong> {{ usuarioActual.apellido }}</p>
        <p><strong>Segundo Apellido:</strong> {{ usuarioActual.segundo_apellido }}</p>
        <p><strong>Correo:</strong> {{ usuarioActual.correo }}</p>
        <p><strong>Teléfono:</strong> {{ usuarioActual.telefono }}</p>
        <p><strong>Edad:</strong> {{ usuarioActual.edad }}</p>
        <p><strong>Dirección:</strong> {{ usuarioActual.direccion }}</p>
        <p><strong>Descripción:</strong> {{ usuarioActual.descripcion }}</p>
        <p><strong>Fecha Registro:</strong> {{ usuarioActual.fecha_registro }}</p>
        <p><strong>Rol:</strong> {{ usuarioActual.rol }}</p>
        <div class="actions-container">
          <button @click="editarUsuario(usuarioActual)" class="edit-btn">Editar</button>
          <button @click="eliminarUsuario(usuarioActual.documento)" class="delete-btn">Eliminar</button>
        </div>
        <div class="nav-buttons">
          <button @click="anteriorUsuario" :disabled="currentIndex === 0">⬅️</button>
          <button @click="siguienteUsuario" :disabled="currentIndex >= usuariosFiltrados.length - 1">➡️</button>
        </div>
      </div>
      <table v-else>
          <thead>
            <tr>
              <th>Documento</th>
              <th>Nombre</th>
              <th>Segundo Nombre</th>
              <th>Apellido</th>
              <th>Segundo Apellido</th>
              <th>Correo</th>
              <th>Teléfono</th>
              <th>Edad</th>
              <th>Dirección</th>
              <th>Descripción</th>
              <th>Fecha Registro</th>
              <th>Rol</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="usuario in usuariosFiltrados" :key="usuario.documento">
              <td>{{ usuario.documento }}</td>
              <td>{{ usuario.nombre }}</td>
              <td>{{ usuario.segundo_nombre }}</td>
              <td>{{ usuario.apellido }}</td>
              <td>{{ usuario.segundo_apellido }}</td>
              <td>{{ usuario.correo }}</td>
              <td>{{ usuario.telefono }}</td>
              <td>{{ usuario.edad }}</td>
              <td>{{ usuario.direccion }}</td>
              <td>{{ usuario.descripcion }}</td>
              <td>{{ usuario.fecha_registro }}</td>
              <td>{{ usuario.rol }}</td>
              <td>
                <div class="actions-container">
                  <button @click="editarUsuario(usuario)" class="edit-btn">Editar</button>
                  <button @click="eliminarUsuario(usuario.documento)" class="delete-btn">Eliminar</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
    </div>

    <div class="form-wrapper">
      <h1>{{ editModeUsuario ? 'Editar Usuario' : 'Agregar Usuario' }}</h1>
      <form @submit.prevent="guardarUsuario">
        <div class="form-group">
          <label for="documento">Documento</label>
          <input type="number" id="documento" v-model="documento" placeholder="Documento" required class="form-input" :disabled="editModeUsuario" />
        </div>
        <div class="form-group">
          <label for="nombre">Nombre:</label>
          <input type="text" id="nombre" v-model="nombre" placeholder="Nombre" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="segundo_nombre">Segundo Nombre:</label>
          <input type="text" id="segundo_nombre" v-model="segundo_nombre" placeholder="Segundo Nombre" class="form-input" />
        </div>
        <div class="form-group">
          <label for="apellido">Apellido:</label>
          <input type="text" id="apellido" v-model="apellido" placeholder="Apellido" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="segundo_apellido">Segundo Apellido:</label>
          <input type="text" id="segundo_apellido" v-model="segundo_apellido" placeholder="Segundo Apellido" class="form-input" />
        </div>
        <div class="form-group">
          <label for="correo">Correo:</label>
          <input type="email" id="correo" v-model="correo" placeholder="Correo" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="telefono">Teléfono:</label>
          <input type="text" id="telefono" v-model="telefono" placeholder="Teléfono" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="edad">Edad:</label>
          <input type="number" id="edad" v-model="edad" placeholder="Edad" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="direccion">Dirección:</label>
          <input type="text" id="direccion" v-model="direccion" placeholder="Dirección" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="descripcion">Descripción:</label>
          <input type="text" id="descripcion" v-model="descripcion" placeholder="Descripción" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="rol">Rol:</label>
          <select id="rol" v-model="rol" required class="form-select">
            <option value="administrador">Administrador</option>
            <option value="operario">Operario</option>
            <option value="coordinador">Coordinador</option>
            <option value="usuario_epp">Usuario EPP</option>
          </select>
        </div>

        <div class="cont-btn">
          <button type="submit" class="form-submit-button">{{ editModeUsuario ? 'Actualizar' : 'Agregar' }}</button>
          <button type="button" @click="resetUsuario" class="form-toggle-button">{{ editModeUsuario ? 'Cancelar Edición' : 'Limpiar Formulario' }}</button>
          <p v-if="errorMessage" class="form-error">{{ errorMessage }}</p>
          <p v-if="successMessage" class="form-success">{{ successMessage }}</p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch,computed, onBeforeUnmount } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';

const searchQuery = ref('');
const usuarios = ref([]);
const usuariosFiltrados = ref([]);
const editModeUsuario = ref(false);
const successMessage = ref('');
const errorMessage = ref('');
const documento = ref('');
const nombre = ref('');
const segundo_nombre = ref('');
const apellido = ref('');
const segundo_apellido = ref('');
const correo = ref('');
const telefono = ref('');
const edad = ref('');
const direccion = ref('');
const descripcion = ref('');
const rol = ref('administrador');
const currentIndex = ref(0);
const isMobile = ref(window.innerWidth <= 420);

const updateScreenSize = () => {
  isMobile.value = window.innerWidth <= 420;
};

onMounted(() => {
  window.addEventListener('resize', updateScreenSize);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateScreenSize);
});


const usuarioActual = computed(() => {
  if (usuariosFiltrados.value.length === 0) return null;
  return usuariosFiltrados.value[currentIndex.value];
});

const siguienteUsuario = () => {
  if (currentIndex.value < usuariosFiltrados.value.length - 1) {
    currentIndex.value++;
  }
};

const anteriorUsuario = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--;
  }
};

// Reinicia índice cuando cambia el filtro
watch(usuariosFiltrados, () => {
  currentIndex.value = 0;
});

const obtenerUsuarios = async () => {
  try {
    const response = await axios.get('https://backendecoentorno-production.up.railway.app/consultarusuarios');
    usuarios.value = response.data;
    usuariosFiltrados.value = usuarios.value; // Inicia con todos los usuarios
  } catch (error) {
    await Swal.fire({
      title: 'Error',
      text: 'Error al obtener la lista de usuarios',
      icon: 'error',
      confirmButtonText: 'Aceptar',
    });
  }
};

// Filtrar usuarios dinámicamente según lo que el usuario escriba
watch(searchQuery, (nuevoValor) => {
  if (nuevoValor === '') {
    usuariosFiltrados.value = usuarios.value; // Si no hay búsqueda, mostrar todos los usuarios
  } else {
    usuariosFiltrados.value = usuarios.value.filter(usuario => 
      usuario.documento.toString().includes(nuevoValor) ||
      usuario.nombre.toLowerCase().includes(nuevoValor.toLowerCase()) ||
      usuario.apellido.toLowerCase().includes(nuevoValor.toLowerCase())
    );
  }
});

const guardarUsuario = async () => {
  const usuario = {
    documento: documento.value,
    nombre: nombre.value,
    segundo_nombre: segundo_nombre.value,
    apellido: apellido.value,
    segundo_apellido: segundo_apellido.value,
    correo: correo.value,
    telefono: telefono.value,
    edad: edad.value,
    direccion: direccion.value,
    descripcion: descripcion.value,
    fecha_registro: new Date().toISOString().split('T')[0],
    rol: rol.value,
  };

  try {
    if (editModeUsuario.value) {
      await axios.put(`https://backendecoentorno-production.up.railway.app/modificarusuario/${usuario.documento}`, usuario);
      await Swal.fire({
        title: 'Éxito',
        text: 'Usuario actualizado exitosamente',
        icon: 'success',
        confirmButtonText: 'Aceptar',
      });
    } else {
      await axios.post('https://backendecoentorno-production.up.railway.app/insertarusuario', usuario);
      await Swal.fire({
        title: 'Éxito',
        text: 'Usuario agregado exitosamente',
        icon: 'success',
        confirmButtonText: 'Aceptar',
      });
    }
    obtenerUsuarios();
    resetUsuario();
  } catch (error) {
    await Swal.fire({
      title: 'Error',
      text: 'Error al guardar el usuario',
      icon: 'error',
      confirmButtonText: 'Aceptar',
    });
  }
};

const editarUsuario = (usuario) => {
  documento.value = usuario.documento;
  nombre.value = usuario.nombre;
  segundo_nombre.value = usuario.segundo_nombre;
  apellido.value = usuario.apellido;
  segundo_apellido.value = usuario.segundo_apellido;
  correo.value = usuario.correo;
  telefono.value = usuario.telefono;
  edad.value = usuario.edad;
  direccion.value = usuario.direccion;
  descripcion.value = usuario.descripcion;
  rol.value = usuario.rol;
  editModeUsuario.value = true;
};

const eliminarUsuario = async (documento) => {
  try {
    const result = await Swal.fire({
      title: '¿Estás seguro?',
      text: '¡No podrás recuperar esta credencial!',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar',
    });
    if (result.isConfirmed) {
      console.log(documento);

    await axios.delete(`https://backendecoentorno-production.up.railway.app/eliminarusuario/${documento}`);
    await Swal.fire({
      title: 'Éxito',
      text: 'Usuario eliminado exitosamente',
      icon: 'success',
      confirmButtonText: 'Aceptar',
    });
    obtenerUsuarios();
  }
  } catch (error) {
    await Swal.fire({
      title: 'Error',
      text: 'Error al eliminar el usuario',
      icon: 'error',
      confirmButtonText: 'Aceptar',
    });
  }

};

const resetUsuario = () => {
  documento.value = '';
  nombre.value = '';
  segundo_nombre.value = '';
  apellido.value = '';
  segundo_apellido.value = '';
  correo.value = '';
  telefono.value = '';
  edad.value = '';
  direccion.value = '';
  descripcion.value = '';
  rol.value = 'administrador';
  editModeUsuario.value = false;
  successMessage.value = '';
  errorMessage.value = '';
};

onMounted(() => {
  obtenerUsuarios();
});
</script>

<style>
/* Estilos para el contenedor de búsqueda */
.search-container {
  display: flex; 
  align-items: center; 
  justify-content: center;
  gap: 10px; 
}

/* Estilos para el input de búsqueda */
.search-input {
  height: 30px;
  padding: 5px;
  margin-top: 20px;
  font-size: 16px; 
  width: 100%; /* Cambié el ancho para ser flexible */
  max-width: 400px; /* Límite máximo de ancho */
  border: 2px solid #ccc; 
  border-radius: 5px;
  outline: none;
  transition: border-color 0.3s ease;
}

/* Estilo para el enfoque del input de búsqueda */
.search-input:focus {
  border-color: #5c8df8; 
}

/* Estilo para el botón de búsqueda */
.search-btn {
  padding: 10px 20px; 
  font-size: 16px; 
  background-color: #5c8df8; 
  color: white;
  border: none; 
  border-radius: 5px; 
  cursor: pointer; 
  transition: background-color 0.3s ease; 
}

/* Efecto hover para el botón de búsqueda */
.search-btn:hover {
  background-color: #4a7df2; 
}

/* Estilo para el contenedor de la tabla */
.table-container {
  width: 80%;
  margin-top: 10px; /* Ajusté el margen superior */
  margin-left: 50px;
}
.Lusu{
  margin-left: 200px;
}
/* Estilos de la tabla */
table {
  background-color: antiquewhite;
  border-collapse: collapse;
}

/* Estilo para las celdas de la tabla */
th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

/* Estilo para los encabezados de la tabla */
th {
  background-color: #f2f2f2;
}

/* Contenedor de las acciones (editar/eliminar) */
.actions-container {
  display: flex;
  gap: 10px;
}

/* Estilo para el botón de editar */
.edit-btn {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

/* Estilo para el botón de eliminar */
.delete-btn {
  background-color: #f44336;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

/* Estilos generales para el formulario */
.form-wrapper {
  background-color: #f9f9f9;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  text-align: center;
  width: 93%;
  margin: 50px;
  padding: 50px; /* Añadí un poco de padding para que no quede pegado a los bordes */
  box-sizing: border-box;
}

.form-container {
  display: flex;
  flex-direction: column;
}

/* Estilo de los grupos de formulario */
.form-group {
  text-align: left;
  margin-bottom: 15px;
}

/* Estilo de los inputs y selects en el formulario */
.form-input, .form-select {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

/* Contenedor para los botones en el formulario */
.cont-btn {
  display: flex;
  justify-content: space-around;
  gap: 10px;
  flex-wrap: wrap; /* Esto ayuda a que los botones se acomoden mejor en pantallas pequeñas */
}

/* Estilo de los botones del formulario */
.form-submit-button, .form-toggle-button {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 10px;
  cursor: pointer;
  border-radius: 4px;
  width: 100%;
  max-width: 200px; /* Asegura que el botón no sea muy ancho en pantallas grandes */
}

/* Estilo para el botón para alternar entre agregar/editar */
.form-toggle-button {
  background-color: #f44336;
  margin-left: 10px;
}

/* Estilos de error y éxito en el formulario */
.form-error, .form-success {
  color: red;
}
@media (max-width:420px){
  .usuario-card {
    background-color: antiquewhite;
    padding: 15px;
    border-radius: 10px;
    margin: 20px 10px;
    box-shadow: 0 0 5px rgba(0,0,0,0.2);
  }

  .nav-buttons {
    display: flex;
    justify-content: space-between;
    margin-top: 10px;
  }

  .nav-buttons button {
    background-color: #5c8df8;
    color: white;
    border: none;
    padding: 10px;
    border-radius: 5px;
    font-size: 16px;
  }

  .nav-buttons button:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }
}
  .search-container {
  display: flex; 
  align-items: center; 
  justify-content: center;
  gap: 10px; 
}

/* Estilos para el input de búsqueda */
.search-input {
  height: 30px;
  padding: 5px;
  margin-top: 20px;
  font-size: 16px; 
  width: 100%; /* Cambié el ancho para ser flexible */
  max-width: 400px; /* Límite máximo de ancho */
  border: 2px solid #ccc; 
  border-radius: 5px;
  outline: none;
  transition: border-color 0.3s ease;
}

/* Estilo para el enfoque del input de búsqueda */
.search-input:focus {
  border-color: #5c8df8; 
}

/* Estilo para el botón de búsqueda */
.search-btn {
  padding: 10px 20px; 
  font-size: 16px; 
  background-color: #5c8df8; 
  color: white;
  border: none; 
  border-radius: 5px; 
  cursor: pointer; 
  transition: background-color 0.3s ease; 
}

/* Efecto hover para el botón de búsqueda */
.search-btn:hover {
  background-color: #4a7df2; 
}

/* Estilo para el contenedor de la tabla */
.table-container {
  width: 100%;
  margin-top: 10px; /* Ajusté el margen superior */
  margin-left: 10px;
}
.Lusu{
  margin-left: 0px;
}
/* Estilos de la tabla */
table {
  width: 0%;
  background-color: antiquewhite;
  border-collapse: collapse;
}

/* Estilo para las celdas de la tabla */
th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

/* Estilo para los encabezados de la tabla */
th {
  background-color: #f2f2f2;
}

/* Contenedor de las acciones (editar/eliminar) */
.actions-container {
  display: flex;
  gap: 10px;
}

/* Estilo para el botón de editar */
.edit-btn {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

/* Estilo para el botón de eliminar */
.delete-btn {
  background-color: #f44336;
  color: white;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 5px;
}

/* Estilos generales para el formulario */
.form-wrapper {
  background-color: #f9f9f9;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  text-align: center;
  margin: 10px;
  padding: 50px; /* Añadí un poco de padding para que no quede pegado a los bordes */
  box-sizing: border-box;
}

.form-container {
  width: 100%;
  display: flex;
  flex-direction: column;
}

/* Estilo de los grupos de formulario */
.form-group {
  width: 100%;
  text-align: left;
  margin-bottom: 15px;
}

/* Estilo de los inputs y selects en el formulario */
.form-input, .form-select {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

/* Contenedor para los botones en el formulario */
.cont-btn {
  display: flex;
  justify-content: space-around;
  gap: 10px;
  flex-wrap: wrap; /* Esto ayuda a que los botones se acomoden mejor en pantallas pequeñas */
}

/* Estilo de los botones del formulario */
.form-submit-button, .form-toggle-button {
  background-color: #4CAF50;
  color: white;
  border: none;
  padding: 10px;
  cursor: pointer;
  border-radius: 4px;
  width: 100%;
  max-width: 200px; /* Asegura que el botón no sea muy ancho en pantallas grandes */
}

/* Estilo para el botón para alternar entre agregar/editar */
.form-toggle-button {
  background-color: #f44336;
  margin-left: 10px;
}

/* Estilos de error y éxito en el formulario */
.form-error, .form-success {
  color: red;
}
</style>
