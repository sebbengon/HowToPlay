<template>
  <div id="controls">
    <audio
      id="fanfare"
      src="../assets/sounds/trumpet-royal-fanfare.mp3"
      preload="auto"
    ></audio>
    <div class="fanfare" v-if="session.isPlayFanfare">
      <audio
        :autoplay="!grimoire.isMuted"
        src="../assets/sounds/trumpet-royal-fanfare.mp3"
        :muted="grimoire.isMuted"
      ></audio>
    </div>
    <span
      class="nomlog-summary"
      v-show="session.voteHistory.length && session.sessionId"
      @click="toggleModal('voteHistory')"
      :title="
        `${session.voteHistory.length} recent ${
          session.voteHistory.length == 1 ? 'nomination' : 'nominations'
        }`
      "
    >
      <font-awesome-icon icon="book-dead" />
      {{ session.voteHistory.length }}
    </span>
    <span
      class="session"
      :class="{
        spectator: session.isSpectator,
        reconnecting: session.isReconnecting
      }"
      v-if="session.sessionId"
      @click="leaveSession"
      :title="
        `${session.playerCount} andra spelare i denna session${
          session.ping ? ' (' + session.ping + 'ms latency)' : ''
        }`
      "
    >
      <font-awesome-icon icon="broadcast-tower" />
      {{ session.playerCount }}
    </span>
    <div class="menu" :class="{ open: grimoire.isMenuOpen }">
      <font-awesome-icon icon="cog" @click="toggleMenu" />
      <ul>
        <li class="tabs" :class="tab">
          <font-awesome-icon icon="book-open" @click="tab = 'grimoire'" />
          <font-awesome-icon icon="broadcast-tower" @click="tab = 'session'" />
          <font-awesome-icon
            icon="users"
            v-if="!session.isSpectator"
            @click="tab = 'players'"
          />
          <font-awesome-icon icon="theater-masks" @click="tab = 'characters'" />
          <font-awesome-icon icon="question" @click="tab = 'help'" />
        </li>

        <template v-if="tab === 'grimoire'">
          <!-- Grimoire -->
          <li class="headline">Rådets Kodex</li>
          <li @click="toggleGrimoire" v-if="players.length">
            <template v-if="!grimoire.isPublic">Göm</template>
            <template v-if="grimoire.isPublic">Visa</template>
            <em>[G]</em>
          </li>
          <li @click="toggleNight" v-if="!session.isSpectator">
            <template v-if="!grimoire.isNight">Byt till Natt</template>
            <template v-if="grimoire.isNight">Byt till Dag</template>
            <em>[S]</em>
          </li>
          <li @click="toggleNightOrder" v-if="players.length">
            Nattordning
            <em>
              <font-awesome-icon
                :icon="[
                  'fas',
                  grimoire.isNightOrder ? 'check-square' : 'square'
                ]"
              />
            </em>
          </li>
          <li v-if="players.length">
            Zoom
            <em>
              <font-awesome-icon
                @click="setZoom(grimoire.zoom - 1)"
                icon="search-minus"
              />
              {{ Math.round(100 + grimoire.zoom * 10) }}%
              <font-awesome-icon
                @click="setZoom(grimoire.zoom + 1)"
                icon="search-plus"
              />
            </em>
          </li>
          <li @click="setBackground">
            Bakgrundsbild
            <em><font-awesome-icon icon="image"/></em>
          </li>
          <li v-if="!edition.isOfficial" @click="imageOptIn">
            <small>Visa egna bilder</small>
            <em
              ><font-awesome-icon
                :icon="[
                  'fas',
                  grimoire.isImageOptIn ? 'check-square' : 'square'
                ]"
            /></em>
          </li>
          <li @click="toggleStatic">
            Inaktivera animationer
            <em
              ><font-awesome-icon
                :icon="['fas', grimoire.isStatic ? 'check-square' : 'square']"
            /></em>
          </li>
          <li @click="toggleMuted">
            Stäng av ljud
            <em
              ><font-awesome-icon
                :icon="['fas', grimoire.isMuted ? 'volume-mute' : 'volume-up']"
            /></em>
          </li>
        </template>

        <template v-if="tab === 'session'">
          <!-- Session -->
          <li class="headline" v-if="session.sessionId">
            {{ session.isSpectator ? "Spelande" : "Värdskap" }}
          </li>
          <li class="headline" v-else>
            Live Session
          </li>
          <template v-if="!session.sessionId">
            <li @click="hostSession">Värd (Berättare)<em>[H]</em></li>
            <li @click="joinSession">Gå med (Spelare)<em>[J]</em></li>
          </template>
          <template v-else>
            <li v-if="!session.isSpectator" @click="playFanfare">
              Spela fanfar
              <em><font-awesome-icon icon="theater-masks"/></em>
            </li>
            <li v-if="session.ping">
              Fördröj till {{ session.isSpectator ? "värden" : "spelarna" }}
              <em>{{ session.ping }}ms</em>
            </li>
            <li @click="copySessionUrl">
              Kopiera spelarlänk
              <em><font-awesome-icon icon="copy"/></em>
            </li>
            <li v-if="!session.isSpectator" @click="distributeRoles">
              Skicka karaktärer
              <em><font-awesome-icon icon="theater-masks"/></em>
            </li>
            <li
              v-if="session.voteHistory.length || !session.isSpectator"
              @click="toggleModal('voteHistory')"
            >
              Rösthistorik<em>[V]</em>
            </li>
            <li @click="leaveSession">
              Lämna Session
              <em>{{ session.sessionId }}</em>
            </li>
          </template>
        </template>

        <template v-if="tab === 'players' && !session.isSpectator">
          <!-- Users -->
          <li class="headline">Spelare</li>
          <li @click="addPlayer" v-if="players.length < 20">
            Lägg till<em>[A]</em>
          </li>
          <li @click="randomizeSeatings" v-if="players.length > 2">
            Slumpa platserna
            <em><font-awesome-icon icon="dice"/></em>
          </li>
          <li @click="clearPlayers" v-if="players.length">
            Ta bort alla
            <em><font-awesome-icon icon="trash-alt"/></em>
          </li>
        </template>

        <template v-if="tab === 'characters'">
          <!-- Characters -->
          <li class="headline">Karaktärer</li>
          <li v-if="!session.isSpectator" @click="toggleModal('edition')">
            Välj Manus
            <em>[E]</em>
          </li>
          <li
            @click="toggleModal('roles')"
            v-if="!session.isSpectator && players.length > 4"
          >
            Välj & Tilldela
            <em>[C]</em>
          </li>
          <li v-if="!session.isSpectator" @click="toggleModal('fabled')">
            Lägg till Legendar
            <em><font-awesome-icon icon="dragon"/></em>
          </li>
          <li @click="clearRoles" v-if="players.length">
            Ta bort alla
            <em><font-awesome-icon icon="trash-alt"/></em>
          </li>
        </template>

        <template v-if="tab === 'help'">
          <!-- Help -->
          <li class="headline">Hjälp</li>
          <li @click="toggleModal('reference')">
            Karaktärsreferens
            <em>[R]</em>
          </li>
          <li @click="toggleModal('expressions')">
            Uttrycksreferens
            <em>[U]</em>
          </li>
          <li @click="toggleModal('nightOrder')">
            Nattordningsblad
            <em>[N]</em>
          </li>
          <li @click="toggleModal('gameState')">
            Spelläge JSON
            <em><font-awesome-icon icon="file-code"/></em>
          </li>
          <li>
            <a href="https://discord.gg/HgDhw6wUP" target="_blank">
              Gå med i Discord
            </a>
            <em>
              <a href="https://discord.gg/HgDhw6wUP" target="_blank">
                <font-awesome-icon :icon="['fab', 'discord']" />
              </a>
            </em>
          </li>
          <li>
            <span>Version 1.1.0</span>
          </li>
        </template>
      </ul>
    </div>
  </div>
</template>

<script>
import { mapMutations, mapState } from "vuex";

export default {
  computed: {
    ...mapState(["grimoire", "session", "edition"]),
    ...mapState("players", ["players"])
  },
  data() {
    return {
      tab: "grimoire"
    };
  },
  methods: {
    setBackground() {
      const background = prompt("Enter custom background URL");
      if (background || background === "") {
        this.$store.commit("setBackground", background);
      }
    },
    hostSession() {
      if (this.session.sessionId) return;
      const sessionId = prompt(
        "Ange ett kanalnummer / namn för din session",
        Math.round(Math.random() * 10000)
      );
      if (sessionId) {
        this.$store.commit("session/clearVoteHistory");
        this.$store.commit("session/setSpectator", false);
        this.$store.commit("session/setSessionId", sessionId);
        this.copySessionUrl();
      }
    },
    copySessionUrl() {
      const url = window.location.href.split("#")[0];
      const link = url + "#" + this.session.sessionId;
      navigator.clipboard.writeText(link);
    },
    distributeRoles() {
      if (this.session.isSpectator) return;
      const popup =
        "Vill du dela ut tilldelade karaktärer till alla SITTADE spelare?";
      if (confirm(popup)) {
        this.$store.commit("session/distributeRoles", true);
        setTimeout(
          (() => {
            this.$store.commit("session/distributeRoles", false);
          }).bind(this),
          2000
        );
      }
    },
    playFanfare() {
      if (this.session.isSpectator) return;
      const popup = "Vill du spela upp Tronsals fanfaren?";
      if (confirm(popup)) {
        this.$store.commit("session/setPlayFanfare", true);
        console.log("true");
        setTimeout(
          (() => {
            this.$store.commit("session/setPlayFanfare", false);
            console.log("false");
          }).bind(this),
          5000
        );
      }
      // const audio = document.getElementById('fanfare')
      // if (confirm('Vill du spela upp Tronsals fanfaren?')) {
      //   console.log('Play Fanfare')
      //   audio.volume = 0.2
      //   audio.play()
      // }
    },
    imageOptIn() {
      const popup =
        "Är du säker på att du vill tillåta egna bilder? En författare av en skadlig skriptfil kan spåra din IP-adress på detta sätt.";
      if (this.grimoire.isImageOptIn || confirm(popup)) {
        this.toggleImageOptIn();
      }
    },
    joinSession() {
      if (this.session.sessionId) return this.leaveSession();
      let sessionId = prompt(
        "Ange kanalnumret / namnet på den session du vill gå med i"
      );
      if (sessionId.match(/^https?:\/\//i)) {
        sessionId = sessionId.split("#").pop();
      }
      if (sessionId) {
        this.$store.commit("session/clearVoteHistory");
        this.$store.commit("session/setSpectator", true);
        this.$store.commit("toggleGrimoire", false);
        this.$store.commit("session/setSessionId", sessionId);
      }
    },
    leaveSession() {
      if (
        confirm("Är du säker på att du vill lämna den aktiva spelomgången?")
      ) {
        this.$store.commit("session/setSpectator", false);
        this.$store.commit("session/setSessionId", "");
      }
    },
    addPlayer() {
      if (this.session.isSpectator) return;
      if (this.players.length >= 20) return;
      const name = prompt("Spelarnamn");
      if (name) {
        this.$store.commit("players/add", name);
      }
    },
    randomizeSeatings() {
      if (this.session.isSpectator) return;
      if (confirm("Är du säker på att du vill slump ut platserna?")) {
        this.$store.dispatch("players/randomize");
      }
    },
    clearPlayers() {
      if (this.session.isSpectator) return;
      if (confirm("Är du säker på att du vill ta bort alla spelare?")) {
        // abort vote if in progress
        if (this.session.nomination) {
          this.$store.commit("session/nomination");
        }
        this.$store.commit("players/clear");
      }
    },
    clearRoles() {
      if (confirm("Är du säker på att du vill ta bort alla spelarroller?")) {
        this.$store.dispatch("players/clearRoles");
      }
    },
    toggleNight() {
      this.$store.commit("toggleNight");
      if (this.grimoire.isNight) {
        this.$store.commit("session/setMarkedPlayer", -1);
      }
    },
    ...mapMutations([
      "toggleGrimoire",
      "toggleMenu",
      "toggleImageOptIn",
      "toggleMuted",
      "toggleNightOrder",
      "toggleStatic",
      "setZoom",
      "toggleModal"
    ])
  }
};
</script>

<style scoped lang="scss">
@import "../vars.scss";

// success animation
@keyframes greenToWhite {
  from {
    color: green;
  }
  to {
    color: white;
  }
}

// Controls
#controls {
  position: absolute;
  right: 3px;
  top: 3px;
  text-align: right;
  padding-right: 50px;
  z-index: 75;

  svg {
    filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.5));
    &.success {
      animation: greenToWhite 1s normal forwards;
      animation-iteration-count: 1;
    }
  }

  > span {
    display: inline-block;
    cursor: pointer;
    z-index: 5;
    margin-top: 7px;
    margin-left: 10px;
  }

  span.nomlog-summary {
    color: $townsfolk;
  }

  span.session {
    color: $demon;
    &.spectator {
      color: $townsfolk;
    }
    &.reconnecting {
      animation: blink 1s infinite;
    }
  }
}

@keyframes blink {
  50% {
    opacity: 0.5;
    color: gray;
  }
}

.menu {
  width: 220px;
  transform-origin: 200px 22px;
  transition: transform 500ms cubic-bezier(0.68, -0.55, 0.27, 1.55);
  transform: rotate(-90deg);
  position: absolute;
  right: 0;
  top: 0;

  &.open {
    transform: rotate(0deg);
  }

  > svg {
    cursor: pointer;
    background: rgba(0, 0, 0, 0.5);
    border: 3px solid black;
    width: 40px;
    height: 50px;
    margin-bottom: -8px;
    border-bottom: 0;
    border-radius: 10px 10px 0 0;
    padding: 5px 5px 15px;
  }

  a {
    color: white;
    text-decoration: none;
    &:hover {
      color: red;
    }
  }

  ul {
    display: flex;
    list-style-type: none;
    padding: 0;
    margin: 0;
    flex-direction: column;
    overflow: hidden;
    box-shadow: 0 0 10px black;
    border: 3px solid black;
    border-radius: 10px 0 10px 10px;

    li {
      padding: 2px 5px;
      color: white;
      text-align: left;
      background: rgba(0, 0, 0, 0.7);
      display: flex;
      align-items: center;
      justify-content: space-between;
      min-height: 30px;

      &.tabs {
        display: flex;
        padding: 0;
        svg {
          flex-grow: 1;
          flex-shrink: 0;
          height: 35px;
          border-bottom: 3px solid black;
          border-right: 3px solid black;
          padding: 5px 0;
          cursor: pointer;
          transition: color 250ms;
          &:hover {
            color: red;
          }
          &:last-child {
            border-right: 0;
          }
        }
        &.grimoire .fa-book-open,
        &.players .fa-users,
        &.characters .fa-theater-masks,
        &.session .fa-broadcast-tower,
        &.help .fa-question {
          background: linear-gradient(
            to bottom,
            $townsfolk 0%,
            rgba(0, 0, 0, 0.5) 100%
          );
        }
      }

      &:not(.headline):not(.tabs):hover {
        cursor: pointer;
        color: red;
      }

      em {
        flex-grow: 0;
        font-style: normal;
        margin-left: 10px;
        font-size: 80%;
      }
    }

    .headline {
      font-family: EagleLake, sans-serif;
      letter-spacing: 1px;
      padding: 0 10px;
      text-align: center;
      justify-content: center;
      background: linear-gradient(
        to right,
        $townsfolk 0%,
        rgba(0, 0, 0, 0.5) 20%,
        rgba(0, 0, 0, 0.5) 80%,
        $demon 100%
      );
    }
  }
}
</style>
