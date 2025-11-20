const { onCall } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const admin = require("firebase-admin");

admin.initializeApp();

// Opcional: limitar instancias
setGlobalOptions({ maxInstances: 10 });

/**
 * Crear usuario con rol sin cerrar la sesión actual.
 * Solo un usuario con rol "admin" puede ejecutar esta función.
 */
exports.createUserWithRole = onCall(async (request) => {
  const context = request.auth;

  // Verificar autenticación
  if (!context) {
    throw new Error("Debes estar autenticado para crear usuarios.");
  }

  // Verificar rol de administrador
  if (!context.token || context.token.role !== "Rector") {
    throw new Error("No tienes permisos para crear usuarios.");
  }

  const { correo, password, rol } = request.data;

  try {
    // Crear usuario con Firebase Admin
    const userRecord = await admin.auth().createUser({
      email: correo,
      password: password
    });

    // Asignar custom claim
    await admin.auth().setCustomUserClaims(userRecord.uid, { rol });

    await admin.firestore().collection("Acudientes").doc(userRecord.uid).set({
      correo,
      rol,
    });

    return {
      message: "Usuario creado correctamente",
      uid: userRecord.uid,
    };

  } catch (error) {
    return {
      error: error.message,
    };
  }
})

exports.setAdminRole = onCall(async (request) => {
  const { uid } = request.data;

  if (!uid) {
    throw new Error("Debes enviar un UID.");
  }

  await admin.auth().setCustomUserClaims(uid, { rol: "Rector" });

  return {
    message: `Rol Rector asignado correctamente al usuario ${uid}`
  };
});