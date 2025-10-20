const admin = require("firebase-admin");
const fs = require("fs");

// ✅ Remplace par ton chemin vers la clé serviceAccount (téléchargeable depuis Firebase Console > Paramètres du projet > Comptes de service)
const serviceAccount = require("/home/patrick/dart/src/veggieharvest-firebase-adminsdk-fbsvc-5355c6b9ad.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// 🔹 Lis le fichier JSON
const data = JSON.parse(fs.readFileSync("vegetables.json", "utf8"));

async function importData() {
  const vegetables = data.vegetables;
  for (const [id, veg] of Object.entries(vegetables)) {
    await db.collection("vegetables").doc(id).set(veg);
    console.log(`✅ Ajouté : ${id}`);
  }
  console.log("🌱 Importation terminée !");
}

importData();
