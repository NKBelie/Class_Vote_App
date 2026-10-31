
const {onCall, HttpsError} =
    require("firebase-functions/v2/https");

const {initializeApp} =
    require("firebase-admin/app");

const {getFirestore} =
    require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

exports.getVoteStatus = onCall(
    {region: "us-central1"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "You must sign in to check your vote.",
        );
      }

      const electionId = request.data?.electionId;

      if (
        typeof electionId !== "string" ||
        !/^[a-zA-Z0-9_-]{1,100}$/.test(electionId)
      ) {
        throw new HttpsError(
            "invalid-argument",
            "A valid election ID is required.",
        );
      }

      const electionRef =
          db.collection("elections").doc(electionId);

      const election = await electionRef.get();

      if (!election.exists) {
        throw new HttpsError(
            "not-found",
            "Election does not exist.",
        );
      }

      const uid = request.auth.uid;

      const voteRef = electionRef
          .collection("votes")
          .doc(uid);

      const vote = await voteRef.get();

      return {
        electionId,
        hasVoted: vote.exists,
      };
    },
);
y