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

      // Intermediates correctos
      const intermediates = stops.map((s) => ({
        location: { latLng: { latitude: s.lat, longitude: s.lng } }
      }));

      const url = "https://routes.googleapis.com/directions/v2:computeRoutes";

      const response = await axios({
        method: "POST",
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": API_KEY,
          "X-Goog-FieldMask": "routes.polyline.encodedPolyline"
        },
        data: {
          origin: {
            location: { latLng: { latitude: origin.lat, longitude: origin.lng } }
          },
          destination: {
            location: { latLng: { latitude: destination.lat, longitude: destination.lng } }
          },
          intermediates: intermediates,
          travelMode: "DRIVE",
          polylineEncoding: "ENCODED_POLYLINE", // <-- NECESARIO
        }
      });

      return res.status(200).json({
        polyline: response.data.routes[0].polyline.encodedPolyline
      });

    } catch (err) {
      console.error("ROUTE ERROR", err);
      return res.status(500).json({ error: err.message });
    }
  }
);

exports.createRouteIda = onRequest(
  { cors: true, secrets: [mapsApiKey] },
  async (req, res) => {
    try {
      const API_KEY = mapsApiKey.value();
      const { placa } = req.body;

      if (!placa) {
        return res.status(400).json({ error: "Falta placa" });
      }

      // Colegio
      const colegio = { lat: 4.1420, lng: -73.6266 };

      // 1. Obtener estudiantes asignados
      const doc = await admin.firestore()
        .collection("RutasGeneradas")
        .doc(placa)
        .get();

      if (!doc.exists) return res.status(404).json({ error: "Ruta no encontrada" });

      const estudiantes = doc.data().estudiantes;

      // 2. Geocoding de cada parada
      const paradas = [];
      for (const est of estudiantes) {
        const geoURL =
          `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(est.direccion)}&key=${API_KEY}`;

        const geoRes = await axios.get(geoURL);

        if (geoRes.data.results.length > 0) {
          const loc = geoRes.data.results[0].geometry.location;

          paradas.push({
            nombre: est.nombre,
            lat: loc.lat,
            lng: loc.lng
          });
        }
      }

      // 3. Ordenar paradas desde el colegio → ida
      const ordenadas = ordenarParadas(colegio, paradas);

      // 4. Llamar a computeRoute (tu backend)
      const routeRes = await axios.post(
        "https://us-central1-school-maps-e69f3.cloudfunctions.net/computeRoute",
        {
          origin: colegio,
          destination: colegio,
          stops: ordenadas,
        }
      );

      const polyline = routeRes.data.polyline;

      // 5. GUARDAR en Firestore
      await admin.firestore()
        .collection("RutasGeneradas")
        .doc(placa)
        .collection("ida")
        .doc("ruta")
        .set({
          paradas: ordenadas,
          polyline: polyline,
          timestamp: new Date(),
        });

      return res.json({
        ok: true,
        paradas: ordenadas,
        polyline: polyline,
      });

    } catch (e) {
      console.error("ERROR createRouteIda:", e);
      return res.status(500).json({ error: e.message });
    }
  }
);

exports.createRouteVuelta = onRequest(
  { cors: true, secrets: [mapsApiKey] },
  async (req, res) => {
    try {
      const API_KEY = mapsApiKey.value();
      const { placa } = req.body;

      if (!placa) {
        return res.status(400).json({ error: "Falta placa" });
      }

      // Colegio
      const colegio = { lat: 4.1420, lng: -73.6266 };

      // 1. Traer estudiantes
      const doc = await admin.firestore()
        .collection("RutasGeneradas")
        .doc(placa)
        .get();

      if (!doc.exists) return res.status(404).json({ error: "Ruta no existe" });

      const estudiantes = doc.data().estudiantes;

      // 2. Geocoding
      const paradas = [];
      for (const est of estudiantes) {
        const geoURL =
          `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(est.direccion)}&key=${API_KEY}`;

        const geoRes = await axios.get(geoURL);

        if (geoRes.data.results.length > 0) {
          const loc = geoRes.data.results[0].geometry.location;

          paradas.push({
            nombre: est.nombre,
            lat: loc.lat,
            lng: loc.lng
          });
        }
      }

      // 3. Ordenar las paradas desde el colegio → ruta optimizada
      const ordenadas = ordenarParadas(colegio, paradas);

      // Última parada = estudiante más lejano
      const destinoFinal = ordenadas[ordenadas.length - 1];

      // 4. Llamar computeRoute
      const routeRes = await axios.post(
        "https://us-central1-school-maps-e69f3.cloudfunctions.net/computeRoute",
        {
          origin: colegio,
          destination: destinoFinal,
          stops: ordenadas.slice(0, -1),
        }
      );

      const polyline = routeRes.data.polyline;

      // 5. Guardar en Firestore
      await admin.firestore()
        .collection("RutasGeneradas")
        .doc(placa)
        .collection("vuelta")
        .doc("ruta")
        .set({
          paradas: ordenadas,
          destinoFinal: destinoFinal,
          polyline: polyline,
          timestamp: new Date(),
        });

      return res.json({
        ok: true,
        paradas: ordenadas,
        destinoFinal,
        polyline,
      });

    } catch (e) {
      console.error("ERROR createRouteVuelta:", e);
      return res.status(500).json({ error: e.message });
    }
  }
);

function distanciaMetros(a, b) {
  const R = 6371e3; // metros
  const dLat = (b.lat - a.lat) * Math.PI/180;
  const dLng = (b.lng - a.lng) * Math.PI/180;
  const lat1 = a.lat * Math.PI/180;
  const lat2 = b.lat * Math.PI/180;

  const h = Math.sin(dLat/2)**2 + Math.cos(lat1)*Math.cos(lat2)*Math.sin(dLng/2)**2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

// retorna una lista de paradas ORDENADAS por cercanía
function ordenarParadas(origin, paradas) {
  const restantes = [...paradas];
  const orden = [];

  let actual = origin;

  while (restantes.length > 0) {
    let mejor = null;
    let distMin = Infinity;

    for (const p of restantes) {
      const d = distanciaMetros(actual, p);
      if (d < distMin) {
        distMin = d;
        mejor = p;
      }
    }

    orden.push(mejor);
    restantes.splice(restantes.indexOf(mejor), 1);
    actual = mejor;
  }

  return orden;
}