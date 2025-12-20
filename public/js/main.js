// Cards section
const getColumnCount = () => {
    const width = window.innerWidth;
    if (width >= 1400) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 1;
};

document.querySelectorAll('.playlist-card__inner').forEach(tile => {
    const card = tile.closest('.playlist-card');
    const collapser = card.querySelector('.js-collapser');

    tile.addEventListener('click', () => {
        const allCards = document.querySelectorAll('.playlist-card');
        const cardsArray = Array.from(allCards);
        const index = cardsArray.indexOf(card);
        const columns = getColumnCount();
        const positionInRow = (index % columns) + 1;
        const isAlreadyOpen = card.classList.contains('is-expanded');

        // Закриваємо всі картки
        allCards.forEach(c => {
            c.classList.remove(
                'is-expanded',
                'is-collapsed',
                'position-1',
                'position-2',
                'position-3',
                'position-4'
            );
            c.classList.add('is-collapsed');
        });

        // Якщо НЕ була відкрита — відкриваємо цю
        if (!isAlreadyOpen) {
            card.classList.add('is-expanded', `position-${positionInRow}`);
            card.classList.remove('is-collapsed');
        }
    });

    // Обробка кліку на "закрити"
    if (collapser) {
        collapser.addEventListener('click', (e) => {
            e.stopPropagation();
            card.classList.remove(
                'is-expanded',
                'position-1',
                'position-2',
                'position-3',
                'position-4'
            );
            card.classList.add('is-collapsed');
        });
    }
});
// END card section
// theme section
document.getElementById("theme-toggle").addEventListener("click", () => {
    const isLight = document.documentElement.classList.contains("light-theme");
    const newTheme = isLight ? "dark" : "light";

    if (newTheme === "light") {
        document.documentElement.classList.add("light-theme");
        document.getElementById("theme-icon").textContent = "🌞";
    } else {
        document.documentElement.classList.remove("light-theme");
        document.getElementById("theme-icon").textContent = "🌙";
    }

    localStorage.setItem("theme", newTheme);
});
// END themesection

// Modal section
const modal = document.getElementById("info-modal");
const openBtn = document.getElementById("open-info-modal");
const closeBtn = modal.querySelector(".close");

openBtn.addEventListener("click", function (e) {
    e.preventDefault();
    modal.style.display = "block";
});

closeBtn.addEventListener("click", function () {
    modal.style.display = "none";
});

window.addEventListener("click", function (e) {
    if (e.target === modal) {
        modal.style.display = "none";
    }
});
// END Modal section
// index.erb Error hide section
const errorMessage = document.getElementById('error-message');
const watchFormInput = document.getElementById('watch-form-input');

if (errorMessage && watchFormInput) {
    watchFormInput.addEventListener('input', function () {
        errorMessage.classList.add('hidden');
    });
}
// END index.erb Error hide section