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

exports.computeRoute = onRequest(
  { cors: true, secrets: [mapsApiKey] },
  async (req, res) => {
    try {
      const API_KEY = mapsApiKey.value();

      const body = req.method === "POST" ? req.body : req.query;

      const origin = body.origin;
      const destination = body.destination;
      const stops = body.stops || [];

      if (!origin || !destination) {
        return res.status(400).json({ error: "Origin and destination required" });
      }

      // Construimos los waypoints
      const intermediates = stops.map((s) => ({
        location: {
          latLng: {
            latitude: s.lat,
            longitude: s.lng,
          },
        },
      }));

      const url =
        `https://routes.googleapis.com/directions/v2:computeRoutes`;

      const response = await axios({
        method: "POST",
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": API_KEY,
          "X-Goog-FieldMask": "routes.polyline.encodedPolyline",
        },
        data: {
          origin: {
            location: {
              latLng: {
                latitude: origin.lat,
                longitude: origin.lng,
              },
            },
          },
          destination: {
            location: {
              latLng: {
                latitude: destination.lat,
                longitude: destination.lng,
              },
            },
          },
          intermediates: intermediates,
          travelMode: "DRIVE",
          optimizeWaypoints: true,
        },
      });

      return res.status(200).json({
        polyline: response.data.routes[0].polyline.encodedPolyline,
      });

    } catch (err) {
      console.error("ROUTE ERROR", err.message);
      return res.status(500).json({ error: err.message });
    }
  }
);
