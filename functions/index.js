const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");
const admin = require("firebase-admin");
const { defineSecret } = require("firebase-functions/params");
const mapsApiKey = defineSecret("GOOGLE_MAPS_API_KEY");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

exports.createFather = onCall(async (request) => {
  const context = request.auth;

  // Verificar autenticación
  if (!context) {
    throw new HttpsError(
      "unauthenticated",
      "Debes estar autenticado para crear usuarios."
    );
  }

  // Verificar rol
  if (!context.token || context.token.rol !== "Rector") {
    throw new HttpsError(
      "permission-denied",
      "No tienes permisos para crear usuarios."
    );
  }

  const { correo, password, rol } = request.data;

  try {
    const userRecord = await admin.auth().createUser({
      email: correo,
      password: password,
    });

    await admin.auth().setCustomUserClaims(userRecord.uid, { rol });

    await admin.firestore()
      .collection("Acudientes")
      .doc(userRecord.uid)
      .set({
        correo,
        rol,
      });

    return {
      message: "Usuario creado correctamente",
      uid: userRecord.uid,
    };

  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

// ===============================================================
// CREAR CONDUCTOR
// ===============================================================

exports.createDriver = onCall(async (request) => {
  const context = request.auth;

  if (!context) {
    throw new HttpsError(
      "unauthenticated",
      "Debes estar autenticado para crear usuarios."
    );
  }

  if (!context.token || context.token.rol !== "Rector") {
    throw new HttpsError(
      "permission-denied",
      "No tienes permisos para crear usuarios."
    );
  }

  const { correo, password, rol } = request.data;

  try {
    const userRecord = await admin.auth().createUser({
      email: correo,
      password: password,
    });

    await admin.auth().setCustomUserClaims(userRecord.uid, { rol });

    await admin.firestore()
      .collection("Conductores")
      .doc(userRecord.uid)
      .set({
        correo,
        rol,
      });

    return {
      message: "Usuario creado exitosamente.",
      uid: userRecord.uid,
    };

  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

// ===============================================================
// ASIGNAR ROL ADMIN
// ===============================================================

exports.setAdminRole = onCall(async (request) => {
  const { uid } = request.data;

  if (!uid) {
    throw new HttpsError("invalid-argument", "Debes enviar un UID.");
  }

  try {
    await admin.auth().setCustomUserClaims(uid, { rol: "Rector" });

    return {
      message: `Rol Rector asignado correctamente al usuario ${uid}`,
    };

  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

exports.getRoute = onRequest(
  { cors: true, secrets: [mapsApiKey] },
  async (req, res) => {
    try {
      const { origin, destination } = req.body;

      if (!origin || !destination) {
        return res.status(400).json({ error: "Origin and destination required" });
      }

      const API_KEY = mapsApiKey.value(); // ← ESTA ES LA CORRECTA

      const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=driving&key=${API_KEY}`;

      const response = await axios.get(url);

      return res.status(200).json(response.data);

    } catch (error) {
      console.error("ERROR DIRECTIONS:", error.message);
      return res.status(500).json({ error: error.message });
    }
  }
);

