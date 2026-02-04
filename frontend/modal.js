function confirmDelete(text) {
        return new Promise(resolve => {
            const modal = document.getElementById("confirm-modal");
            const yes = document.getElementById("confirm-yes");
            const no = document.getElementById("confirm-no");
            const textparagraphe = document.getElementById("modal-text");
            textparagraphe.innerText = text;

            modal.hidden = false;

            yes.onclick = () => {
            modal.hidden = true;
            resolve(true);
            };

            no.onclick = () => {
            modal.hidden = true;
            resolve(false);
            };
        });
    }
