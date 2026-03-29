<template>
  <div class="intro">
    <img src="../assets/cotc-logo.png" alt="" class="logo" />
    <div>
      Välkommen till den virtuella
      <b>Övre salen och Klocktornets Kodex</b> för Council of the Clocktower! Lägg till fler spelare genom
      <span class="button" @click="toggleMenu">
        <font-awesome-icon icon="cog" /> Meny
      </span>
      uppe till höger eller genom att trycka <b>[A]</b>. Du kan också gå med i
      en spelsession genom att trycka på <b>[J]</b>.<br />
      <div class="footer">
        Det här projektet är gratis och har öppen källkod samt en ny variant med
        nytt tema av spelet Blood on the Clocktower. Huvudrepo finns på
        <a href="https://github.com/bra1n/townsquare" target="_blank">GitHub</a
        >. Det är inte kopplat till Pandemonium Institute. "Blood on the
        Clocktower" är ett varumärke för Steven Medway och The Pandemonium
        Institute.
      </div>
    </div>
    <a
      class="redirect"
      v-if="language === 'zh-CN'"
      href="https://clocktower.gstonegames.com"
    >
      <img src="../assets/gstone.png" class="gstone" alt="" />
      你想使用中文版魔典吗？
    </a>
  </div>
</template>

<script>
import { mapMutations } from "vuex";

export default {
  data() {
    return {
      language: window.navigator.userLanguage || window.navigator.language
    };
  },
  methods: mapMutations(["toggleMenu"])
};
</script>

<style scoped lang="scss">
// Intro
.intro {
  text-align: center;
  width: 50%;
  font-size: 120%;
  position: absolute;
  padding: 10px;
  background: rgba(0, 0, 0, 0.5);
  border: 3px solid black;
  border-radius: 10px;
  z-index: 3;
  display: flex;
  justify-content: center;
  a {
    color: white;
  }
  a.redirect {
    display: block;
    text-decoration: none;
    position: absolute;
    top: 100%;
    margin-top: 2vh;
    padding: 10px;
    background: rgba(0, 0, 0, 0.5);
    border: 3px solid black;
    border-radius: 10px;

    &:hover {
      color: red;
    }
    img {
      width: 120px;
      display: block;
      margin: auto;
      margin-bottom: 1vh;
    }
  }

  img.logo {
    position: absolute;
    bottom: 100%;
    width: 50vh;
  }
  .footer {
    font-size: 60%;
    opacity: 0.75;
  }
}
</style>
