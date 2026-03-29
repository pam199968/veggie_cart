const {onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const nodemailer = require("nodemailer");

// Initialisation Firebase Admin
initializeApp();

exports.sendWeeklyOfferEmail = onCall(
    {secrets: ["GMAIL_EMAIL", "GMAIL_PASSWORD"]},
    async (request) => {
      const gmailEmail = process.env.GMAIL_EMAIL;
      const gmailPassword = process.env.GMAIL_PASSWORD;

      console.log("Email utilisé :", gmailEmail ? "OK" : "Non défini");
      console.log("Mot de passe défini :", !!gmailPassword);

      const mailTransport = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: gmailEmail,
          pass: gmailPassword,
        },
      });

      const offer = request && request.data ? request.data.offer : null;

      console.log("Offer reçue :", offer);

      if (!offer) {
        console.error("Aucune offre fournie");
        throw new Error("Les données de l’offre sont manquantes.");
      }

      try {
        const db = getFirestore();

        const usersSnapshot = await db
            .collection("users")
            .where("pushNotifications", "==", true)
            .where("profile", "==", "customer")
            .where("isActive", "==", true)
            .get();

        console.log(`Nombre d'utilisateurs à notifier : ${usersSnapshot.size}`);
        if (usersSnapshot.empty) {
          console.log("Aucun utilisateur à notifier.");
          return {success: true, message: "Aucun utilisateur à notifier."};
        }
        // 🔹 Construction de la liste des légumes en texte formaté
        let vegetablesText = "";
        if (offer.vegetables && Array.isArray(offer.vegetables) &&
        offer.vegetables.length > 0) {
          vegetablesText = "\n🧺 Légumes disponibles cette semaine :\n\n";
          vegetablesText += offer.vegetables.map((veg) => {
            const price = veg.price ? `${veg.price.toFixed(2)} €` : "—";
            const packaging = veg.packaging || "N/A";
            const qty = veg.standardQuantity !== undefined &&
            veg.standardQuantity !== null ?
            veg.standardQuantity : "—";
            return `• ${veg.name} — ${price} / ` +
            `${packaging} (Conditionnement : ${qty} ${packaging})`;
          }).join("\n");
          vegetablesText += "\n\n";
        }
        const sendEmailPromises = [];

        usersSnapshot.forEach((doc) => {
          const user = doc.data();
          if (!user.email) return;

          const mailOptions = {
            from: gmailEmail,
            to: user.email,
            subject: `Nouvelle offre : ${offer.title}`,
            text:
            `Bonjour ${user.givenName} ${user.name || ""},\n\n` +
            `Découvrez notre nouvelle offre de la semaine du ` +
            `${offer.startDate} au ${offer.endDate} !\n\n` +
            `${offer.description}\n\n` +
            `${vegetablesText}` +
            `À très bientôt !\n\n` +
            `— L’équipe du Bi'O jardin 🌱`,
          };

          sendEmailPromises.push(mailTransport.sendMail(mailOptions));
        });

        await Promise.all(sendEmailPromises);

        console.log("Tous les emails ont été envoyés avec succès.");
        return {success: true};
      } catch (error) {
        console.error("Erreur lors de l’envoi des emails :", error);
        throw new Error("Erreur lors de l’envoi des emails : " + error.message);
      }
    });

exports.deleteUserAuth = onCall(async (request) => {
  // 🔐 1️⃣ Vérification authentification
  if (!request.auth) {
    throw new Error("Non authentifié");
  }

  const requesterUid = request.auth.uid;
  const targetUid = request.data && request.data.uid;

  if (!targetUid) {
    throw new Error("UID cible manquant");
  }

  if (requesterUid === targetUid) {
    throw new Error("Suppression de son propre compte interdite");
  }

  const db = getFirestore();

  try {
    // 🔎 2️⃣ Récupération des profils
    const requesterDoc = await db.collection("users").doc(requesterUid).get();
    const targetDoc = await db.collection("users").doc(targetUid).get();

    if (!requesterDoc.exists) {
      throw new Error("Utilisateur demandeur introuvable");
    }

    if (!targetDoc.exists) {
      throw new Error("Utilisateur cible introuvable");
    }

    const requesterData = requesterDoc.data();
    const targetData = targetDoc.data();

    // 🛑 3️⃣ Vérification du rôle du demandeur
    if (requesterData.profile !== "gardener") {
      throw new Error("Permission refusée : seul un gardener peut supprimer");
    }

    // 🛑 4️⃣ Vérification de la cible
    if (targetData.profile !== "customer") {
      throw new Error("Impossible de supprimer un utilisateur non customer");
    }

    // 🔥 5️⃣ Suppression Auth
    await getAuth().deleteUser(targetUid);

    // 🔥 6️⃣ Suppression Firestore
    await db.collection("users").doc(targetUid).delete();

    console.log(`Utilisateur ${targetUid} supprimé par ${requesterUid}`);

    return {success: true};
  } catch (error) {
    console.error("Erreur suppression sécurisée :", error);
    throw new Error(error.message || "Erreur lors de la suppression");
  }
});
